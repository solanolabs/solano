# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

module Solano
  class SolanoCli < Thor
    desc "stop [SESSION]", "Stop session by id"
    def stop(ls_id=nil)
      solano_setup({:scm => false})
      if ls_id then
        begin
          say "Stoping session #{ls_id} ..."
          say @solano_api.stop_session(ls_id)['notice']
        rescue 
        end
      else
        exit_failure 'Stop requires a session id -- e.g. `solano stop 7869764`'
      end
    end
  end
end
