# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

module Solano
  class SCM
    def self.configure
      scm = nil
      ok = false
      scms = [::Solano::Git, ::Solano::Hg]

      # Select SCM based on command availability and current repo type
      scms.each do |scm_class|
        sniff_scm = scm_class.new
        if sniff_scm.repo? && scm_class.version_ok then
          ok = true
          scm = sniff_scm
          break
        end
      end

      # Fall back to first SCM type that is available
      if !ok then
        scms.each do |scm_class|
          sniff_scm = scm_class.new
          if scm_class.version_ok then
            ok = true
            scm = sniff_scm
            break
          end
        end
      end

      # Default to a null SCM implementation
      scm ||= ::Solano::StubSCM.new
      return [scm, ok]
    end
  end
end
