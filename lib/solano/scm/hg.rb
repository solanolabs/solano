# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

require 'uri'
require 'shellwords'

module Solano
  class Hg < SCM
    include SolanoConstant

    def initialize
      super
    end

    def scm_name
      return 'hg'
    end

    def repo?
      if File.directory?('.hg') then
        return true
      end
      ignore = `hg status 2>&1`
      ok = $?.success?
      return ok
    end

    def root
      root = `hg root`
      if $?.exitstatus == 0 then
        root.chomp! if root
        return root
      end
      return Dir.pwd
    end

    def repo_name
      return File.basename(self.root)
    end

    def origin_url
      return @default_origin_url if @default_origin_url

      result = `hg paths default`
      return nil unless $?.success?
      return nil if result.empty?
      result.strip!
      u = URI.parse(result) rescue nil
      if u && u.host.nil? then
        warn(Text::Warning::HG_PATHS_DEFAULT_NOT_URI)
        return nil
      end
      return result
    end

    def ignore_path
      path = File.join(self.root, Config::HG_IGNORE)
      return path
    end

    def current_branch
      branch = `hg branch`
      branch.chomp!
      return branch
    end

    def default_branch
      # NOTE: not necessarily quite right in HG 2.1+ with a default bookmark
      return "default"
    end

    def changes?(options={})
      return Solano::Hg.hg_changes?(:exclude=>".hgignore")
    end

    def hg_push(uri)
      cmd = "hg push -f -b #{self.current_branch} "
      cmd += " #{uri}"

      # git outputs something to stderr when it runs git push.
      # hg doesn't always ... so show the command that's being run and its
      # output to indicate progress.
      puts cmd
      puts `#{cmd}`
      return [0,1].include?( $?.exitstatus )
    end

    def push_latest(session_data, suite_details, options={})
      uri = if options[:use_private_uri] then
              suite_details["git_repo_private_uri"] || suite_details["git_repo_uri"]
            else
              suite_details["git_repo_uri"]
            end
      self.hg_push(uri)
    end

    def current_commit
      commit = `hg id -i`
      commit.chomp!
      return commit
    end

    def commits
      commits = HgCommitLogParser.new(self.latest_commit).commits
      return commits
    end

    def number_of_commits(id_from, id_to)
      result = `hg log --template='{node}\\n' #{id_from}..#{id_to}`
      result.split("\n").length
    end

    def create_snapshot(session_id, options={})
      api = options[:api]
      res = api.request_snapshot_url({:session_id => session_id})
      auth_url = res['auth_url']

      say Text::Process::SNAPSHOT_URL % auth_url

      unique = SecureRandom.hex(10)
      snaphot_path = File.join(Dir.tmpdir,".solano-#{unique}-snapshot")
      file = File.join(Dir.tmpdir, "solano-#{unique}-snapshot.tar")

      # #git default branch
      # branch = options[:default_branch]
      # branch ||= /\-\>.*\/(.*)$/.match( (`git branch -r | grep origin/HEAD`).strip)[1]

      # if branch.nil? then
      #   raise Text::Error::DEFAULT_BRANCH
      # end

      out = `hg clone #{root} #{snaphot_path}`
      out = `tar -C #{snaphot_path} -czpf #{file} .`
      upload_file(auth_url, file)
      Dir.chdir(snaphot_path){
        @snap_id = (`hg --debug id -i`).strip
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

    def create_patch(session_id, options={})
      api = options[:api]
      snapshot_commit = options[:commit]
      if "#{snapshot_commit}" == `hg --debug id -i`.to_s.strip then
        say Text::Warning::SAME_SNAPSHOT_COMMIT
        return
      end
      #check if commit is known locally
      if (`hg log --rev "ancestors(.) and #{snapshot_commit}" 2>&1 >/dev/null | grep -o 'error:' | wc -l`).to_i > 0 then
        raise Text::Error::PATCH_CREATION_ERROR % snapshot_commit
      end

      file_name = "solano-#{SecureRandom.hex(10)}.patch"
      tmp_dir = Dir.mktmpdir("patches")
      file_path = File.join(tmp_dir, file_name)
      Dir
      out = `hg export -o #{tmp_dir}/patch-%n -r #{snapshot_commit}:tip`
      say out
      build_patch(tmp_dir, file_path)

      file_size = File.size(file_path)
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
                :size => file_size,}
      api.upload_session_patch(args)

    ensure
      FileUtils.rm_rf(file_path) if file_path && File.exists?(file_path)
      FileUtils.rm_rf(tmp_dir) if tmp_dir && File.exists?(tmp_dir)
    end

    protected

    def build_patch(tmp_dir, file_path)
      #patch currently includes one two many commits
      files = Dir.glob(File.join(tmp_dir,"patch-*"))
      files.sort!
      files.shift

      File.open( file_path, "w" ){|f_out|
        files.each {|f_name|
          File.open(f_name){|f_in|
            f_in.each {|f_str| f_out.puts(f_str) }
          }
        }
      }
    end

    def latest_commit
      `hg log -f -l 1 --template='{node}\\n{desc|firstline}\\n{author|user}\\n{author|email}\\n{date}\\n{author|user}\\n{author|email}\\n{date}\\n\\n'`
    end

    class << self
      include SolanoConstant

      def hg_changes?(options={})
        options[:exclude] ||= []
        options[:exclude] = [options[:exclude]] unless options[:exclude].is_a?(Array)
        cmd = "hg status -mardu"
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

      def hg_push(this_branch, additional_refs=[])
        raise "not implemented"
      end

      def version_ok
        version = nil
        begin
          version_string = `hg -q --version`
          m =  version_string.match(Dependency::VERSION_REGEXP)
          version = m[0] unless m.nil?
        rescue Errno
        rescue Exception
        end
        if version.nil? || version.empty? then
          return false
        end
        version_parts = version.split(".")
        if version_parts[0].to_i < 2 then
          warn(Text::Warning::HG_VERSION % version)
        end
        true
      end
    end
  end
end
