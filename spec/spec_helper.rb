# Copyright (c) 2011-2016 Solano Labs All Rights Reserved

require 'simplecov'
SimpleCov.start do
  add_filter "spec/"
end

require 'solano'

require 'rspec'
require 'fakefs/spec_helpers'

require 'ostruct'
require 'stringio'
require 'fileutils'

class Open3SpecHelper
  def self.stubOpen2e(data, ok, block)
    stdin = StringIO.new
    output = StringIO.new(data)
    status = (ok && 0) || 1
    value = OpenStruct.new(:exitstatus => status, :to_i => status)
    wait = OpenStruct.new(:value => value)
    block.call(stdin, output, wait)
  end
end

def env_save
  return ENV.to_hash.dup
end

def env_restore(env)
  env.each_pair do |k, v|
    ENV[k] = v
  end
end

shared_context "solano_api_stubs" do
  let(:api_config) { double(Solano::ApiConfig, :get_branch => nil) }
  let(:solano_api) { double(Solano::SolanoAPI) }
  let(:tddium_client) { double(TddiumClient::InternalClient) }

  def stub_solano_api
    allow(solano_api).to receive(:user_logged_in?).and_return(true)
    allow(solano_api).to receive(:get_suites).and_return({})
    allow(Solano::SolanoAPI).to receive(:new).and_return(solano_api)
  end

  def stub_tddium_client
    allow(tddium_client).to receive(:caller_version=).and_return(nil)
    allow(tddium_client).to receive(:call_api).and_return(nil)
    allow(TddiumClient::InternalClient).to receive(:new).and_return(tddium_client)
  end

  before do
    stub_tddium_client
    stub_solano_api
  end
end
