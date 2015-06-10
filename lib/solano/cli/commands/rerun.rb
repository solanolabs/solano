# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

module Solano
  class SolanoCli < Thor
    desc "rerun SESSION", "Rerun failing tests from a session"
    method_option :account, :type => :string, :default => nil,
      :aliases => %w(--org --organization)
    method_option :max_parallelism, :type => :numeric, :default => nil
    method_option :no_op, :type=>:boolean, :default => false, :aliases => ["-n"]
    method_option :force, :type=>:boolean, :default => false
    method_option :profile, :type => :string, :default => nil, :aliases => %w(--profile-name)
    def rerun(session_id=nil)
      params = {:scm => true, :repo => false}
      if session_id.nil? then
        params = {:repo => true, :suite => true}
      end
      solano_setup(params)

      session_id ||= session_id_for_current_suite

      begin
        result = @solano_api.query_session_tests(session_id)
      rescue TddiumClient::Error::API => e
        exit_failure Text::Error::NO_SESSION_EXISTS
      end

      tests = result['session']['tests']
      tests = tests.select{ |t| [
        'failed', 'error', 'notstarted', 'started'].include?(t['status']) }
      tests = tests.map{ |t| t['test_name'] }

      profile = options[:profile]

      cmd = "solano run"
      cmd += " --max-parallelism=#{options[:max_parallelism]}" if options[:max_parallelism]
      cmd += " --org=#{options[:account]}" if options[:account]
      cmd += " --force" if options[:force]
      cmd += " --profile=#{profile}" if profile
      cmd += " #{tests.join(" ")}"

      say cmd
      Kernel.exec(cmd) if !options[:no_op]
    end

    private

    def session_id_for_current_suite
      return unless suite_for_current_branch?
      suite_params = {
        :suite_id => @solano_api.current_suite_id,
        :active => false,
        :limit => 1,
        :origin => %w(ci cli)
      }
      session = @solano_api.get_sessions(suite_params)
      session[0]["id"]
    end
  end
end
