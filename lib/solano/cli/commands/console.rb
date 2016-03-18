# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

require 'stringio'

module Solano
  class SolanoCli < Thor
    desc "console", "Open an ssh Debug Console to the Solano worker"
    method_option :json, :type => :boolean, :default => false
    method_option :commit, :type => :string, :default => nil
    def console
      solano_setup({:repo => true})
      origin = `git config --get remote.origin.url`.strip
      session_result = @solano_api.call_api(:get, "/sessions", {:repo_url => origin})["sessions"][0]

      say "CONSOLE! sessions are #{session_result}"
      q_result = @solano_api.query_session(session_result["id"])
      say "query result is #{q_result.tddium_response}"
      #session_id = 454
      #suite_id = 4
      #result = @solano_api.start_console(session_id, suite_id)
      #puts result.tddium_response.inspect
    end

    private 

  end
end  
