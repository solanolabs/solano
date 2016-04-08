# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

module Solano
  class SolanoCli < Thor
    include SolanoConstant
    extend ParamsHelper

    attr_reader :scm
    attr_reader :user_details

    params = self.load_params

    class_option :host, :type => :string,
                        :default => self.default_host(params),
                        :desc => "Solano CI app server hostname"

    class_option :port, :type => :numeric,
                        :default => self.default_port(params),
                        :desc => "Solano CI app server port"

    class_option :proto, :type => :string,
                         :default => self.default_proto(params),
                         :desc => "API Protocol"

    class_option :insecure, :type => :boolean,
                            :default => self.default_insecure(params),
                            :desc => "Don't verify Solano CI app SSL server certificate"

    def initialize(*args)
      super(*args)

      # TODO: read host from .solano file
      # TODO: allow selecting which .solano "profile" to use
      cli_opts = options[:insecure] ? { :insecure => true } : {}
      cli_opts[:debug] = true
      @tddium_client = TddiumClient::InternalClient.new(options[:host],
                                                        options[:port],
                                                        options[:proto],
                                                        1,
                                                        caller_version,
                                                        cli_opts)
      @tddium_clientv3 = TddiumClient::InternalClient.new(options[:host],
                                                        options[:port],
                                                        options[:proto],
                                                        "api/v3",
                                                        caller_version,
                                                        cli_opts)
      @cli_options = options
    end


    require 'solano/cli/commands/account'
    require 'solano/cli/commands/activate'
    require 'solano/cli/commands/api'
    require 'solano/cli/commands/heroku'
    require 'solano/cli/commands/login'
    require 'solano/cli/commands/logout'
    require 'solano/cli/commands/password'
    require 'solano/cli/commands/rerun'
    require 'solano/cli/commands/find_failing'
    require 'solano/cli/commands/spec'
    require 'solano/cli/commands/stop'
    require 'solano/cli/commands/suite'
    require 'solano/cli/commands/status'
    require 'solano/cli/commands/console'
    require 'solano/cli/commands/keys'
    require 'solano/cli/commands/config'
    require 'solano/cli/commands/describe'
    require 'solano/cli/commands/web'
    require 'solano/cli/commands/github'
    require 'solano/cli/commands/hg'
    require 'solano/cli/commands/server'
    require 'solano/cli/commands/support'

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
      if params[:deprecated] then
        say Text::Error::COMMAND_DEPRECATED
      end

      # suite => repo => scm
      params[:suite] = params[:suite] == true

      params[:repo] = params[:repo] == true
      params[:repo] ||= params[:suite]

      params[:scm] = !params.member?(:scm) || params[:scm] == true
      params[:scm] ||= params[:repo]

      params[:login] = true unless params[:login] == false

      $stdout.sync = true
      $stderr.sync = true

      set_shell

      @scm, ok = Solano::SCM.configure
      if params[:scm] && !ok then
        say Text::Error::SCM_NOT_FOUND
        exit_failure
      end

      @repo_config = RepoConfig.new(@scm)
      if origin_url = @repo_config[:origin_url] then
        @scm.default_origin_url = origin_url
      end

      host = @cli_options[:host]
      @api_config = ApiConfig.new(@scm, @tddium_client, host, @cli_options)
      @solano_api = SolanoAPI.new(@scm, @tddium_client, @api_config, {v3: @tddium_clientv3})

      @api_config.set_api(@solano_api)

      begin
        @api_config.load_config
      rescue ::Solano::SolanoError => e
        say e.message
        exit_failure
      end

      user_details = @solano_api.user_logged_in?(true, params[:login])
      if params[:login] && user_details.nil? then
        exit_failure
      end

      if params[:repo] then
        if !@scm.repo? then
          say Text::Error::SCM_NOT_A_REPOSITORY
          exit_failure
        end

        if @scm.origin_url.nil? then
          say Text::Error::SCM_NO_ORIGIN
          exit_failure
        end

        begin
          Solano::SCM.valid_repo_url?(@scm.origin_url)
        rescue SolanoError => e
          say e.message
          exit_failure
        end
      end

      if params[:suite] then
        if @scm.current_branch.nil? then
          say Text::Error::SCM_NO_BRANCH
          exit_failure
        end

        if !suite_for_current_branch? then
          exit_failure
        end
      end

      @user_details = user_details
    end
  end
end
