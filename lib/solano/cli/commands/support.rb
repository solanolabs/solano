# Copyright (c) 2015 Solano Labs All Rights Reserved

module Solano
  class SolanoCli < Thor
    desc "support", "Generate support json dump"
    define_method "support:dump" do |*args|
      user_details = solano_setup({:login => false, :scm => false})

      login_options = options.dup

      support_data = {}

      support_data['gem_version'] = Solano::VERSION
      support_data['scm'] = @scm.support_data
      support_data['user_details'] = user_details
      support_data['api_config'] = @api_config.config

      support_data = support_data.dup
      ::Solano.sensitive(support_data)

      puts JSON.pretty_generate(support_data)
    end
  end
end
