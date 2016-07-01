# Copyright (c) 2011-2016 Solano Labs All Rights Reserved

require 'stringio'
require 'json'
require 'time'

module Solano
  class SolanoCli < Thor
    desc "console [COMMAND]", "Open an ssh Debug Console to the Solano worker, execute command if given else start shell."
    method_option :json, :type => :boolean, :default => false
    method_option :commit, :type => :string, :default => nil
    def console(*cmd)
      solano_setup({:repo => true})
      origin = `git config --get remote.origin.url`.strip
      session_result = @solano_api.call_api(:get, "/sessions", {:repo_url => origin})["sessions"]
      if session_result.length > 0 then
        session = session_result[0]
        session_id = session["id"]
        q_result = @solano_api.query_session(session_id).tddium_response["session"]
        suite_id = q_result["suite_id"]
        start_result = @solano_api.start_console(session_id, suite_id).tddium_response
        session_id = start_result["interactive_session_id"] # the new interactive session's id
        if start_result["message"] == "interactive started" then
          say "Starting console session #{session_id}"
          ssh_command = nil
          failures = 0
          while !ssh_command do
            sleep(Default::SLEEP_TIME_BETWEEN_POLLS)
            begin
              session = @solano_api.query_session(session_id).tddium_response["session"]
              failures = 0 # clear any previous transient failures
            rescue Exception => e
              failures += 1
              say e.to_s
              session = {}
            end
            if failures > 2 then
              say "Errors connecting to server"
              return # give up.
            end
            if session["stage2_ready"] && session["ssh_command"] then
              if cmd then
                ssh_command = "#{session['ssh_command']} -o StrictHostKeyChecking=no \"#{cmd.join(' ')}\""
              else
                ssh_command = "#{session['ssh_command']} -o StrictHostKeyChecking=no"
              end
            end
          end
          say "SSH Command is #{ssh_command}"
          # exec terminates this ruby process and lets user control the ssh i/o
          exec ssh_command
        elsif start_result["message"] == "interactive already running"
          dur = duration(Time.parse(start_result['session']['expires_at']) - Time.now)
          say "Interactive session already running (expires in #{dur})"
          session_id = start_result["session"]["id"]
          session = @solano_api.query_session(session_id).tddium_response["session"]
          if cmd then
            exec "#{session['ssh_command']} -o StrictHostKeyChecking=no \"#{cmd.join(' ')}\""
          else
            exec "#{session['ssh_command']} -o StrictHostKeyChecking=no"
          end
        else
          say start_result["message"]
        end
      else
        say "Unable to find any previous sessions. Execute solano run first"
      end
    end

    private 
    # return nice string version of hrs mins secs from time delta
    def duration(d)
      secs = d.to_int
      mins = secs / 60
      hours = mins / 60
      if hours > 0 then
        "#{hours} hours #{mins % 60} minutes"
      elsif mins > 0 then
        "#{mins} minutes #{secs % 60} seconds"
      else
        "#{secs} seconds"
      end
    end
  end
end  
