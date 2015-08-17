# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

module Solano
  class SolanoCli < Thor
    desc "api:key", "Display Solano CI API Key"
    define_method "api:key" do
      user_details = solano_setup({:scm => false})
      api_key = user_details['api_key']
      if api_key.nil? then
        exit_failure LIST_API_KEY_ERROR
      end
      say api_key
    end
  end
end  
