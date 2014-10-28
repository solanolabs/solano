# Copyright (c) 2014 Solano Labs All Rights Reserved

require 'spec_helper'
require 'solano/agent'

describe "Agent (unstubbed)" do
  it "should attach a file to session" do
    if ENV['SOLANO'] then
      agent = Solano::BuildAgent.new
      agent.attach_file('/etc/hosts')
    end
  end

  it "should attach a file to test" do
    if ENV['SOLANO'] then
      agent = Solano::BuildAgent.new
      agent.attach_file('/etc/resolv.conf', {:exec_id => agent.test_exec_id})
    end
  end
end
