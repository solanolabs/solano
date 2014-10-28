# Copyright (c) 2011, 2012, 2013, 2014 Solano Labs All Rights Reserved

require "solano/constant"
require "solano/version"

require "solano/util"

require "solano/scm"
require "solano/ssh"

module Solano
  class SolanoError < Exception
    attr_reader :message

    def initialize(message)
      @message = message
    end
  end
end
