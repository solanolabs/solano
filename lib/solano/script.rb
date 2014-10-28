# Copyright (c) 2014 Solano Labs, Inc. All Rights Reserved
#
module Solano
  class Scripts
    include SolanoConstant
    def self.prepend_script_path
      path = ENV['PATH'].split(':')
      path.unshift(Config::EMBEDDED_SCRIPT_PATH)
      ENV['PATH'] = path.join(':')
    end
  end
end
