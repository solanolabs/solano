# Copyright (c) 2014 Solano Labs All Rights Reserved

require 'spec_helper'
require 'solano/constant'
require 'solano/cli/params_helper'

describe ParamsHelper do
  extend ParamsHelper
  around do |example|
    orig_env = ENV.to_hash
    example.run
    ENV.update(orig_env)
  end

  describe '.default_host' do
    it 'return host params if it is present' do
      params = {'host' => 'host.example' }
      expect(self.class.default_host(params)).to eq(params['host'])
    end

    it 'returns SOLANO_CLIENT_HOST variable if it is present' do
      ENV.clear
      ENV['SOLANO_CLIENT_HOST'] = 'host.example'
      expect(self.class.default_host({})).to eq(ENV['SOLANO_CLIENT_HOST'])
    end

    it 'returns TDDIUM_CLIENT_HOST variable if it is present' do
      ENV.clear
      ENV['TDDIUM_CLIENT_HOST'] = 'host.example'
      expect(self.class.default_host({})).to eq(ENV['TDDIUM_CLIENT_HOST'])
    end

    it 'returns default host if host params and env varable are not present' do
      ENV.clear
      expect(self.class.default_host({})).to eq('ci.solanolabs.com')
    end
  end

  describe '.default_port' do
    it 'returns port params if it is present' do
      params = { 'port' => '3001' }
      expect(self.class.default_port(params)).to eq(params['port'])
    end

    it 'returns SOLANO_CLIENT_PORT if it is present' do
      ENV.clear
      ENV['SOLANO_CLIENT_PORT'] = '3001'
      expect(self.class.default_port({})).to eq(ENV['SOLANO_CLIENT_PORT'].to_i)
    end

    it 'returns TDDIUM_CLIENT_PORT if it is present' do
      ENV.clear
      ENV['TDDIUM_CLIENT_PORT'] = '3001'
      expect(self.class.default_port({})).to eq(ENV['TDDIUM_CLIENT_PORT'].to_i)
    end

    it 'returns nil if port params and env variables are not present' do
      ENV.clear
      expect(self.class.default_port({})).to eq(nil)
    end
  end

  describe '.default_proto' do
    it 'returns proto param if it is present' do
      params = { 'proto' => 'http' }
      expect(self.class.default_proto(params)).to eq(params['proto'])
    end

    it 'returns SOLANO_CLIENT_PROTO if it is present' do
      ENV.clear
      ENV['SOLANO_CLIENT_PROTO'] = 'http'
      expect(self.class.default_proto({})).to eq(ENV['SOLANO_CLIENT_PROTO'])
    end

    it 'returns TDDIUM_CLIENT_PROTO if it is present' do
      ENV.clear
      ENV['TDDIUM_CLIENT_PROTO'] = 'https'
      expect(self.class.default_proto({})).to eq(ENV['TDDIUM_CLIENT_PROTO'])
    end

    it 'returns default proto if proto param and evm variables are not present' do
      ENV.clear
      expect(self.class.default_proto({})).to eq('https')
    end
  end

  describe '.default_insecure' do
    it 'returns insecure param if it is present' do
      params = { 'insecure' => false }
      expect(self.class.default_insecure(params)).to eq(params['insecure'])
    end

    it 'returns true if SOLANO_CLIENT_INSECURE is present' do
      ENV.clear
      ENV['SOLANO_CLIENT_INSECURE'] = 'true'
      expect(self.class.default_insecure({})).to eq(true)
    end

    it 'returns true if TDDIUM_CLIENT_INSECURE is present' do
      ENV.clear
      ENV['TDDIUM_CLIENT_INSECURE'] = 'true'
      expect(self.class.default_insecure({})).to eq(true)
    end

    it 'returns false if insecure param and evn variables are not present' do
      ENV.clear
      expect(self.class.default_insecure({})).to eq(false)
    end
  end
end
