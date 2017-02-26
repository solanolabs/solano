# Copyright (c) 2011, 2012, 2013, 2014 Solano Labs All Rights Reserved

require 'spec_helper'
require 'solano/cli'
require 'solano/cli/commands/stop'

describe Solano::SolanoCli do
  describe "#stop" do
    include_context "solano_api_stubs"

    let(:ls_id) { 123 }
    let(:stop_session_result) {
      {'status'=>'0', 'notice'=>"Stopped session #{ls_id}"}
    }

    it "should produce a command line from an old session's results" do
      solano_api.should_receive(:stop_session).with(ls_id).and_return(stop_session_result)
      subject.should_receive(:say).with("Stopping session #{ls_id} ...")
      subject.should_receive(:say).with(stop_session_result['notice'])

      subject.stop(ls_id)
    end

    it "returns non-zero status code in case of failure" do
      subject.should_receive(:exit_failure)
      subject.stop
    end
  end
end
