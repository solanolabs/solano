# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

module Solano
  class SolanoCli < Thor
    desc "web [SESSION_ID]", "Open build report in web browser"
    def web(*args)
      session_id = args.first

      params = {:login => false}
      if session_id.nil? then
        params[:scm] = true
        params[:repo] = true
      end

      solano_setup(params)

      if session_id
        fragment = "1/reports/#{session_id}" if session_id =~ /^(\d+)(\.\w+)*$/
      end
      fragment ||= 'latest'

      begin
        Launchy.open("#{options[:proto]}://#{options[:host]}/#{fragment}")
      rescue Launchy::Error => e
        exit_failure e.message
      end
    end
  end
end
