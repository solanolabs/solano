# Copyright (c) 2011-2016 Solano Labs All Rights Reserved

module Solano
  class Git < SCM
    include SolanoConstant

    def initialize
      super
    end

    def scm_name
      return 'git'
    end

    def repo?
      if File.directory?('.git') then
        return true
      end
      ignore = `git status 2>&1`
      ok = $?.success?
      return ok
    end

    def root
      root = `git rev-parse --show-toplevel 2>&1`
      if $?.exitstatus == 0 then
        root.chomp! if root
        return root
      end
      return Dir.pwd
    end

    def mirror_path
      return nil
    end

    def repo_name
      return File.basename(self.root)
    end

    def origin_url
      return @default_origin_url if @default_origin_url

      result = `git config --get remote.origin.url`
      return nil unless $?.success?

      result = result.strip

      # no slashes before first colon
      # [user@]host.xz:path/to/repo.git/
      scp_pat = /^([A-Za-z0-9_]+@)?([A-Za-z0-9._-]+):\/?([^\/].*)/
      if m = scp_pat.match(result) then
        result = "ssh://#{m[1]}#{m[2]}/#{m[3]}"
      end

      return result
    end

    def ignore_path
      path = File.join(self.root, Config::GIT_IGNORE)
      return path
    end

    def current_branch
      `git symbolic-ref HEAD`.gsub("\n", "").split("/")[2..-1].join("/")
    end

    def default_branch
      `git remote show origin | grep HEAD | awk '{print $3}'`.gsub("\n", "")
    end

    # XXX DANGER: This method will edit the current workspace.  It's meant to
    # be run to make a git mirror up-to-date.
    def checkout(branch, options={})
      if !!options[:update] then
        `git fetch origin`
        return false if !$?.success?
      end

      cmd = "git checkout "
      if !!options[:force] then
        cmd += "-f "
      end
      cmd += Shellwords.shellescape(branch)
      `#{cmd}`

      return false if !$?.success?

      `git reset --hard origin/#{branch}`
      return $?.success?
    end

    def changes?(options={})
      return Solano::Git.git_changes?(:exclude=>".gitignore")
    end

    def push_latest(session_data, suite_details, options={})
      branch = options[:branch] || self.current_branch
      remote_branch = options[:remote_branch] || branch
      git_repo_uri = if options[:git_repo_uri] then
                       options[:git_repo_uri]
                     elsif options[:use_private_uri] then
                       suite_details["git_repo_private_uri"] || suite_details["git_repo_uri"]
                     else
                       suite_details["git_repo_uri"]
                     end
      this_ref = (session_data['commit_data'] || {})['git_ref']
      refs = this_ref ? ["HEAD:#{this_ref}"] : []

      if options[:git_repo_origin_uri] then
        Solano::Git.git_set_remotes(options[:git_repo_origin_uri], 'origin')
      end

      Solano::Git.git_set_remotes(git_repo_uri)
      return Solano::Git.git_push(branch, refs, remote_branch)
    end

    def current_commit
      `git rev-parse --verify HEAD`.strip
    end

    def commits
      commits = GitCommitLogParser.new(self.latest_commit).commits
      return commits
    end

    def number_of_commits(id_from, id_to)
      result = `git log --pretty='%H' #{id_from}..#{id_to}`
      result.split("\n").length
    end

    def offer_snapshot_creation(session_id)
      say Test::Process::ASK_FOR_SNAPSHOT
      answer = gets.chomp
      if /Y/.match(answer) then
        create_snapshot(session_id, { :force=>true })
      else
        raise Text::Error::ANSWER_NOT_Y
      end
    end

    def create_snapshot(session_id, options={})
      api = options[:api]
      res = api.request_snapshot_url({:session_id => session_id})
      auth_url = res['auth_url']

      say Text::Process::SNAPSHOT_URL % auth_url

      unique = SecureRandom.hex(10)
      snaphot_path = File.join(Dir.tmpdir,".solano-#{unique}-snapshot")
      file = File.join(Dir.tmpdir, "solano-#{unique}-snapshot.tar")

      if !options[:force] then
        #git default branch
        branch = options[:default_branch]
        branch ||= default_branch
        if branch.nil? then
          raise Text::Error::DEFAULT_BRANCH
        end
        if branch == (`git rev-parse --abbrev-ref HEAD`).strip && !/Your branch is up-to-date with/.match(`git status`).nil? then
          raise Text::Error::NEED_TO_FORCE % branch
        end
        say Text::Process::CREATING_REPO_SNAPSHOT_BRANCH % [root, branch]
        out = `git clone --mirror -b #{branch} #{root} #{snaphot_path}`
        if !$?.success? then
          raise Text::Error::FAILED_TO_CREATE_SNAPSHOT % out
        end
      else
        say Text::Process::CREATING_REPO_SNAPSHOT % root
        out = `git clone --mirror #{root} #{snaphot_path}`
        if !$?.success? then
          raise Text::Error::FAILED_TO_CREATE_SNAPSHOT % out
        end
      end
      out = `tar -C #{snaphot_path} -czpf #{file} .`
      upload_file(auth_url, file)
      Dir.chdir(snaphot_path){
        @snap_id = (`git rev-parse HEAD`).strip
      }

      desc = {"url" => auth_url.gsub(/\?.*/,''),
        "size" => File.stat(file).size,
        "sha1"=> Digest::SHA1.file(file).hexdigest.upcase,
        "commit_id"=> @snap_id,
        "session_id" => session_id,
      }
      api.update_snapshot({:repo_snapshot => desc})
    ensure
      FileUtils.rm_rf(snaphot_path) if snaphot_path && File.exists?(snaphot_path)
      FileUtils.rm_f(file) if file && File.exists?(file)
    end

    def create_patch(session_id, snapshot_commit, options={})
      api = options[:api]
      patch_base = options[:commit]
      base_commit = patch_base
      if "#{patch_base}" == self.current_commit then
        say Text::Warning::SAME_SNAPSHOT_COMMIT
        return
      end
      #check if snapshot commit is known locally
      `git branch -q --contains #{patch_base}`
      if !$?.success? then
        #try and create a patch from upstream instread of repo snapshot
        upstream = origin_url
        reg = Regexp.new('([^\s]*)\s*' + upstream.to_s + '\s*\(fetch\)')
        if !upstream.nil? && (reg_match = reg.match(`git remote`)) then
          say TEXT::Process::ATTEMPT_UPSTREAM_PATCH % upstream
          #should be the remote name
          patch_base = reg_match[1]
          base_commit = `git rev-parse #{patch_base}`.to_s.strip
        else
          say Text::Error::PATCH_CREATION_ERROR % patch_base
          offer_snapshot_creation(session_id)
          return
        end
      end

      file_name = "solano-#{SecureRandom.hex(10)}.patch"
      file_path = File.join(Dir.tmpdir, file_name)
      say Text::Process::CREATING_PATCH % [patch_base, self.current_commit]
      out = `git diff --minimal -p --ignore-space-at-eol --no-prefix #{patch_base}..#{self.current_commit} > #{file_path}`
      if !$?.success? then
        say Text::Error::FAILED_TO_CREATE_PATCH % [patch_base, out]
        offer_snapshot_creation(session_id)
        return
      end

      file_size = File.size(file_path)
      if file_size != 0 then

        file_sha1 = Digest::SHA1.file(file_path).hexdigest.upcase

        #upload patch
        say Text::Process::REQUST_PATCH_URL
        res = api.request_patch_url({:session_id => session_id})
        if (auth_url = res['auth_url']) then
          say Text::Process::UPLOAD_PATCH % auth_url
          upload_file(auth_url, file_path)
        else
          raise Text::Error::NO_PATCH_URL
        end

        args = {  :session_id => session_id,
                  :sha1 => file_sha1,
                  :size => file_size,
                  :base_commit => base_commit,
                  :snapshot_commit => snapshot_commit}
        api.upload_session_patch(args)
      else
        say Text::Warning::EMPTY_PATCH
        return
      end

    ensure
      FileUtils.rm_rf(file_path) if file_path && File.exists?(file_path)
    end

    protected

    def latest_commit
      `git log --pretty='%H%n%s%n%aN%n%aE%n%at%n%cN%n%cE%n%ct%n' -1`
    end

    class << self
      include SolanoConstant

      def git_changes?(options={})
        options[:exclude] ||= []
        options[:exclude] = [options[:exclude]] unless options[:exclude].is_a?(Array)
        cmd = "git status --porcelain -uno"
        p = IO.popen(cmd)
        changes = false
        while line = p.gets do
          line = line.strip
          status, name = line.split(/\s+/)
          next if options[:exclude].include?(name)
          if status !~ /^\?/ then
            changes = true
            break
          end
        end
        unless $?.success? then
          warn(Text::Warning::SCM_UNABLE_TO_DETECT)
          return false
        end
        return changes
      end

      def git_set_remotes(git_repo_uri, remote_name=nil)
        remote_name ||= Config::REMOTE_NAME

        unless `git remote show -n #{remote_name}` =~ /#{git_repo_uri}/
          IO.popen("git remote rm #{remote_name}") {} # Discard output on *nix & windows
          `git remote add #{remote_name} #{git_repo_uri.shellescape}`
        end
      end

      def git_push(this_branch, additional_refs=[], remote_branch=nil)
        say Text::Process::SCM_PUSH
        remote_branch ||= this_branch
        refs = ["#{this_branch}:#{remote_branch}"]
        refs += additional_refs
        refspec = refs.map(&:shellescape).join(" ")
        cmd = "git push -f #{Config::REMOTE_NAME} #{refspec}"
        say "Running '#{cmd}'"
        system(cmd)
      end

      def version_ok
        version = nil
        begin
          version_string = `git --version`
          m =  version_string.match(Dependency::VERSION_REGEXP)
          version = m[0] unless m.nil?
        rescue Errno
        rescue Exception
        end
        if version.nil? || version.empty? then
          return false
        end
        version_parts = version.split(".")
        if version_parts[0].to_i < 1 ||
           (version_parts[0].to_i < 2 && version_parts[1].to_i == 1 && version_parts[1].to_i < 7) then
          warn(Text::Warning::GIT_VERSION % version)
        end
        true
      end
    end
  end
end
