# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

module Solano
  class SCM
    attr_accessor :default_origin_url

    def initialize
      @default_origin_url = nil
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
