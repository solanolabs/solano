# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

module Solano
  class SCM
    attr_accessor :default_origin_url

    def initialize
      @default_origin_url = nil
    end

    def support_data
      data = Hash.new
      data['scm_name'] = self.scm_name
      if !self.repo? then
        data['is_repo'] = false
        return data
      end

      %w(scm_name repo? root repo_name origin_url current_branch default_branch changes?).each do |method|
        key = method
        if method =~ /[?]\z/ then
          key = "is_#{method.sub(/[?]\z/, '')}"
        end

        value = self.send(method.to_sym) rescue nil

        data[key] = value
      end

      return data
    end

    def scm_name
    end

    def repo?
      return false
    end

    def root
      return Dir.pwd
    end

    def repo_name
      return "unknown"
    end

    def origin_url
      return @default_origin_url
    end

    def ignore_path
      return nil
    end

    def current_branch
      return nil
    end

    def default_branch
      return nil
    end

    def changes?(options={})
      return false
    end

    def push_latest(session_data, suite_details, options={})
      return false
    end

    def create_snapshot(session_id, options={})
      say Text::Error:SNAPSHOT_NOT_SUPPORTED
      raise
    end

    def create_patch(session_id, options={})
      say "patch creation not supported"
      raise
    end

    def upload_file(auth_url, file_path)
      if (`which curl >/dev/null 2>&1 ; echo $?`).to_i == 0 then
        `curl -f --upload-file "#{file_path}" "#{auth_url}"`
        if(`echo $?`).to_i == 22  then
          say "Failed to upload #{file_path} URL (#{out.code})"
          raise
        end
      else
        uri = URI(auth_url)
        body = File.read(file_path)
        out = Net::HTTP.start(uri.host, :use_ssl => true) do |http|
            http.send_request("PUT", uri.request_uri, body, {"content-type" => "",})
        end
        if out.code.to_i != 200
          say "Failed to upload to #{file_path} (#{out.code})"
          raise
        end
      end
    end


    def current_commit
      return nil
    end

    def commits
      []
    end

    def number_of_commits(id_from, id_to)
      return 0
    end

    def latest_commit
      return nil
    end
  end
end
