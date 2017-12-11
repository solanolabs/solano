# Copyright (c) 2011-2017 Solano Labs All Rights Reserved

require 'stringio'

module Solano
  class SolanoCli < Thor
    desc "status", "Display information about this suite, and any open dev sessions"
    method_option :json, :type => :boolean, :default => false
    method_option :commit, :type => :string, :default => nil
    method_option :account, :type => :string, :default => nil,
                  :aliases => %w(--org --organization)
    def status
      solano_setup({:repo => true})

      begin
        # solano_setup asserts that we're in a supported SCM repo
        origin_url = @scm.origin_url
        repo_params = {
          :active => true,
          :repo_url => origin_url
        }

        if suite_for_current_branch? then
          status_branch = @solano_api.current_branch
          suite_params = {
            :active => false,
            :limit => 10
          }
        elsif suite_for_default_branch? then
          status_branch = @solano_api.default_branch
          say Text::Error::TRY_DEFAULT_BRANCH % status_branch
          suite_params = {
            :active => false,
            :limit => 10
          }
        end

        if options[:commit] then
          repo_params[:last_commit_id] = options[:commit]
          suite_params[:last_commit_id] = options[:commit]
        end

        suites = @solano_api.get_suites(:repo_url => origin_url, :branch => status_branch)
        if suites.count == 0
          exit_failure Text::Error::CANT_FIND_SUITE % [origin_url, status_branch]
        elsif suites.count > 1
          if options[:account] then
            suites = suites.select { |s| s['account'] == options[:account] }
          else
            say Text::Status::SUITE_IN_MULTIPLE_ACCOUNTS % [origin_url, status_branch]
            suites.each { |s| say '  ' + s['account'] }
            account = ask Text::Status::SUITE_IN_MULTIPLE_ACCOUNTS_PROMPT
            suites = suites.select { |s| s['account'] == account }
          end
        end

        if suites.count == 0
          exit_failure Text::Error::INVALID_ACCOUNT_NAME
        end

        suite_params[:suite_id] = suites.first['id']

        if options[:json] 
          res = {}
          res[:running] = { origin_url => @solano_api.get_sessions(repo_params) }          
          res[:history] = { 
            status_branch => @solano_api.get_sessions(suite_params)
          } if suite_params
          puts JSON.pretty_generate(res)
        else
          show_session_details(
            status_branch,
            repo_params, 
            Text::Status::NO_ACTIVE_SESSION, 
            Text::Status::ACTIVE_SESSIONS,
            true
          )
          show_session_details(
            status_branch,
            suite_params, 
            Text::Status::NO_INACTIVE_SESSION, 
            Text::Status::INACTIVE_SESSIONS,
            false
          ) if suite_params
          say Text::Process::RERUN_SESSION
        end

      rescue TddiumClient::Error::Base => e
        exit_failure e.message
      end
    end

    private 

    def show_session_details(status_branch, params, no_session_prompt, all_session_prompt, include_branch)
      current_sessions = @solano_api.get_sessions(params)

      say ""
      if current_sessions.empty? then
        say no_session_prompt
      else
        commit_size = 0...7
        head = @scm.current_commit[commit_size]

        say all_session_prompt % (params[:suite_id] ? status_branch : "")
        say ""
        header = ["Session #", "Commit", ("Branch" if include_branch), "Status", "Duration", "Started"].compact
        table = [header, header.map { |t| "-" * t.size }] + current_sessions.map do |session|
          duration = "%ds" % session['duration']
          start_timeago = "%s ago" % Solano::TimeFormat.seconds_to_human_time(Time.now - Time.parse(session["start_time"]))
          status = session["status"]
          if status.nil? || status.strip == "" then
            status = 'unknown'
          end

          [
            session["id"].to_s,
            session["commit"] ? session['commit'][commit_size] : '-      ',
            (session["branch"] if include_branch),
            status,
            duration,
            start_timeago
          ].compact
        end
        say(capture_stdout { print_table table }.gsub(head, "\e[7m#{head}\e[0m"))
      end
    end

    def capture_stdout
      old, $stdout = $stdout, StringIO.new
      yield
      $stdout.string
    ensure
      $stdout = old
    end
  end
end  
