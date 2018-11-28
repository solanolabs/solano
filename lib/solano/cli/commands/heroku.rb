# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

module Solano
  class SolanoCli < Thor
    desc "heroku", "Connect Heroku account with Solano CI (deprecated)"
    method_option :email, :type => :string, :default => nil
    method_option :password, :type => :string, :default => nil
    method_option :ssh_key_file, :type => :string, :default => nil
    method_option :app, :type => :string, :default => nil
    def heroku
      say "To activate your heroku account, please visit"
      say "https://ci.predix.io/"

      solano_setup({:scm => false})
    end
  end
end
