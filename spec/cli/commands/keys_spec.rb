# Copyright (c) 2014 Solano Labs All Rights Reserved

require 'spec_helper'
require 'solano/constant'
require 'solano/cli'
require 'solano/cli/commands/keys'

describe Solano::SolanoCli do
  include_context 'solano_api_stubs'

  describe '.keys:add' do
    it 'calls correct method' do
      Solano::Ssh.should_receive(:validate_keys).with('some_key', '/home/.ssh/id_rsa.pub', solano_api)
      solano_api.should_receive(:set_keys).and_return({'gitserver' => 'api.tddium.com'})

      subject.send('keys:add', 'some_key', '/home/.ssh/id_rsa.pub')
    end
  end

  describe '.keys:gen' do
    it 'calls corrent method' do
      Solano::Ssh.should_receive(:validate_keys).with(
                                                      'some_key',
                                                      Solano::SolanoCli::Default::SSH_OUTPUT_DIR,
                                                      solano_api,
                                                      true
                                                      )
      solano_api.should_receive(:set_keys).and_return({'gitserver' => 'api.tddium.com'})

      subject.send('keys:gen', 'some_key')
    end
  end
end
