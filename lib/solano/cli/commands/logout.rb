# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

module Solano
  class SolanoCli < Thor
    desc "logout", "Log out of solano"
    def logout
      solano_setup({:login => false, :scm => false})

      @api_config.logout

      say Text::Process::LOGGED_OUT_SUCCESSFULLY
    end
  end
end
