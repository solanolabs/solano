# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

module Solano
  class SCM
    def self.configure
      scm = nil
      [::Solano::Git, ::Solano::Hg].each do |scm_class|
        sniff_scm = scm_class.new
        if sniff_scm.repo? && scm_class.version_ok
          scm = sniff_scm
          break
        end
      end

      # default scm is null SCM
      scm ||= ::Solano::StubSCM.new
      return scm
    end
  end
end
