# Copyright (c) 2011, 2012, 2013, 2014 Solano Labs All Rights Reserved

module Solano
  class SolanoCli < Thor
    protected

    def update_suite(suite, options)
      params = {}
      prompt_suite_params(options, params, suite)

      ask_or_update = lambda do |key, text, default|
        params[key] = prompt(text, options[key], suite.fetch(key.to_s, default), options[:non_interactive])
      end

      ask_or_update.call(:campfire_room, Text::Prompt::CAMPFIRE_ROOM, '')
      ask_or_update.call(:hipchat_room, Text::Prompt::HIPCHAT_ROOM, '')

      @solano_api.update_suite(suite['id'], params)
      say Text::Process::UPDATED_SUITE
    end

    def suite_auto_configure
      # Did the user set a configuration option on the command line?
      # If so, auto-configure a new suite and re-configure an existing one
      user_config = options.member?(:tool)

      current_suite_id = @solano_api.current_suite_id
      if current_suite_id && !user_config then
        current_suite = @solano_api.get_suite_by_id(current_suite_id)
      else
        params = Hash.new
        params[:branch] = @scm.current_branch
        params[:repo_url] = @scm.origin_url
        params[:repo_name] = @scm.repo_name
        params[:scm] = @scm.scm_name
        if options[:account] && !params.member?(:account_id) then
          account_id = @solano_api.get_account_id(options[:account])
          params[:account_id] = account_id if account_id
        end

        tool_cli_populate(options, params)
        defaults = {}

        prompt_suite_params(options.merge({:non_interactive => true}), params, defaults)

        # Create new suite if it does not exist yet
        say Text::Process::CREATING_SUITE % [params[:repo_name], params[:branch]]

        current_suite = @solano_api.create_suite(params)

        # Save the created suite
        @api_config.set_suite(current_suite)
        @api_config.write_config
      end
      return current_suite
    end

    def format_suite_details(suite)
      # Given an API response containing a "suite" key, compose a string with
      # important information about the suite
      solano_deploy_key_file_name = @api_config.solano_deploy_key_file_name
      details = ERB.new(Text::Status::SUITE_DETAILS).result(binding)
      details
    end

    def suite_for_current_branch?
      return true if @solano_api.current_suite_id
      say Text::Error::NO_SUITE_EXISTS % @scm.current_branch
      false
    end

    def suite_for_default_branch?
      return true if @solano_api.default_suite_id
      say Text::Error::NO_SUITE_EXISTS % @scm.default_branch
      false
    end

    # repo_config_file has authority over solano.yml now
    # Update the suite parameters from solano.yml
    #def update_suite_parameters!(current_suite, session_id=nil)
    #end

    def suite_remembered_option(options, key, default, &block)
      remembered = false
      if options[key] != default
        result = options[key]
      elsif remembered = current_suite_options[key.to_s]
        result = remembered
        remembered = true
      else
        result = default
      end

      if result then
        msg = Text::Process::USING_SPEC_OPTION[key] % result
        msg +=  Text::Process::REMEMBERED if remembered
        msg += "\n"
        say msg
        yield result if block_given?
      end
      result
    end
  end
end
