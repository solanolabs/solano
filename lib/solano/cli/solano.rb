# Copyright (c) 2011, 2012, 2013, 2014 Solano Labs All Rights Reserved

module Solano
  class SolanoCli < Thor
    include SolanoConstant
    extend ParamsHelper
    
    attr_reader :scm
    attr_reader :user_details

    params = self.load_params

    class_option :host, :type => :string, 
                        :default => params['host'] || ENV['SOLANO_CLIENT_HOST'] || "ci.solanolabs.com",
                        :desc => "Solano CI app server hostname"

    class_option :port, :type => :numeric,
                        :default => params['port'] || (ENV['SOLANO_CLIENT_PORT'].nil? ? nil : ENV['SOLANO_CLIENT_PORT'].to_i),
                        :desc => "Solano CI app server port"

    class_option :proto, :type => :string,
                         :default => params['proto'] || ENV['SOLANO_CLIENT_PROTO'] || "https",
                         :desc => "API Protocol"

    class_option :insecure, :type => :boolean, 
                            :default => params.key?('insecure') ? params['insecure'] : (ENV['SOLANO_CLIENT_INSECURE'] != nil),
                            :desc => "Don't verify Solano CI app SSL server certificate"

    def initialize(*args)
      super(*args)

      # XXX TODO: read host from .solano file, allow selecting which .solano "profile" to use
      cli_opts = options[:insecure] ? { :insecure => true } : {}
      @tddium_client = TddiumClient::InternalClient.new(options[:host], 
                                                        options[:port], 
                                                        options[:proto], 
                                                        1, 
                                                        caller_version, 
                                                        cli_opts)

      @scm = Solano::SCM.configure

      @api_config = ApiConfig.new(@tddium_client, options[:host], options)
      @repo_config = RepoConfig.new
      @solano_api = SolanoAPI.new(@api_config, @tddium_client, @scm)

      # BOTCH: fugly
      @api_config.set_api(@solano_api)
    end


    require "solano/cli/commands/account"
    require "solano/cli/commands/activate"
    require "solano/cli/commands/heroku"
    require "solano/cli/commands/login"
    require "solano/cli/commands/logout"
    require "solano/cli/commands/password"
    require "solano/cli/commands/rerun"
    require "solano/cli/commands/find_failing"
    require "solano/cli/commands/spec"
    require "solano/cli/commands/stop"
    require "solano/cli/commands/suite"
    require "solano/cli/commands/status"
    require "solano/cli/commands/keys"
    require "solano/cli/commands/config"
    require 'solano/cli/commands/describe'
    require "solano/cli/commands/web"
    require 'solano/cli/commands/github'
    require 'solano/cli/commands/hg'
    require 'solano/cli/commands/server'

    map "-v" => :version
    desc "version", "Print the solano gem version"
    def version
      say VERSION
    end

    # Thor has the wrong default behavior
    def self.exit_on_failure?
      return true
    end

    # Thor prints a confusing message for the "help" command in case an option
    # follows in the wrong order before the command.
    # This code patch overwrites this behavior and prints a better error message.
    # For Thor version >= 0.18.0, release 2013-03-26.
    if defined? no_commands
      no_commands do
        def invoke_command(command, *args)
          begin
            super
          rescue InvocationError
            if command.name == "help"
              exit_failure Text::Error::CANT_INVOKE_COMMAND
            else
              raise
            end
          end
        end
      end
    end

    protected

    def caller_version
      "solano-#{VERSION}"
    end

    def configured_test_pattern
      pattern = @repo_config["test_pattern"]

      return nil if pattern.nil? || pattern.empty?
      return pattern
    end

    def configured_test_exclude_pattern
      pattern = @repo_config["test_exclude_pattern"]

      return nil if pattern.nil? || pattern.empty?
      return pattern
    end

    def solano_setup(params={})
      params[:scm] = !params.member?(:scm) || params[:scm] == true
      params[:login] = true unless params.member?(:login)
      params[:repo] = params[:repo] == true
      params[:suite] = params[:suite] == true

      $stdout.sync = true
      $stderr.sync = true

      set_shell

      @api_config.load_config

      user_details = @solano_api.user_logged_in?(true, params[:login])
      if params[:login] && user_details.nil? then
        exit_failure
      end

      if params[:repo] && !@scm.repo? then
        say Text::Error::SCM_NOT_A_REPOSITORY
        exit_failure
      end

      if params[:suite] && !suite_for_current_branch? then
        exit_failure
      end

      @user_details = user_details
    end
  end
end
