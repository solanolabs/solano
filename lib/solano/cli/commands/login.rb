# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

module Solano
  class SolanoCli < Thor
    desc "login [[TOKEN]]", "Log in using your email address or token (see: https://ci.predix.io/user_settings/token)"
    method_option :email, :type => :string, :default => nil
    method_option :password, :type => :string, :default => nil
    method_option :ssh_key_file, :type => :string, :default => nil
    def login(*args)
      user_details = solano_setup({:login => false, :scm => false})

      login_options = options.dup

      if args.first && args.first =~ /@/
        login_options[:email] ||= args.first 
      elsif args.first
        # assume cli token
        login_options[:cli_token] = args.first
      end

      if user_details then
        say Text::Process::ALREADY_LOGGED_IN
      elsif user = @solano_api.login_user(:params => @solano_api.get_user_credentials(login_options), :show_error => true)
        say Text::Process::LOGGED_IN_SUCCESSFULLY 
        if @scm.repo? then
          @api_config.populate_branches(@solano_api.current_branch)
        end
        @api_config.write_config
      else
        exit_failure
      end
      if prompt_missing_ssh_key then
        say Text::Process::NEXT_STEPS
      end
    end
  end
end
