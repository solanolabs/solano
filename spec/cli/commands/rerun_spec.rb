# Copyright (c) 2011, 2012, 2013, 2014 Solano Labs All Rights Reserved

require 'spec_helper'
require 'solano/cli'
require 'solano/cli/commands/spec'

describe Solano::SolanoCli do
  describe "#rerun" do
    include_context "solano_api_stubs"

    let(:session_id) { 123 }
    let(:query_session_result) {
      {'session'=> {'tests' => [{'status'=>'failed', 'test_name'=>'foo.rb'}]}}
    }

    it "should produce a command line from an old session's results" do
      solano_api.should_receive(:query_session).with(session_id).and_return(query_session_result)
      Kernel.should_receive(:exec).with(/solano run foo.rb/)

      subject.rerun(session_id)
    end

    it "should produce a command line from an last session's results" do
      solano_api.should_receive(:current_suite_id).exactly(3).times.and_return(123)
      solano_api.should_receive(:get_sessions).and_return([{"id" => 1234}])
      solano_api.should_receive(:query_session).with(1234).and_return(query_session_result)
      Kernel.should_receive(:exec).with(/solano run foo.rb/)

      subject.rerun
    end
  end
end
