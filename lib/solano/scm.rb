# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

module Solano
  class SCM
    SCMS = %w(git hg)
  end
end

require 'solano/scm/git_log_parser'
require 'solano/scm/hg_log_parser'

require 'solano/scm/configure'
require 'solano/scm/url'

require 'solano/scm/scm'
require 'solano/scm/scm_stub'
require 'solano/scm/git'
require 'solano/scm/hg'
