# Copyright (c) 2011, 2012, 2013, 2014, 2015 Solano Labs All Rights Reserved

require 'spec_helper'
require 'solano/cli'
require 'solano/cli/commands/spec'

describe Solano::SolanoCli do
  describe "#rerun" do
    include_context "solano_api_stubs"

    let(:session_id) { 123 }
    let(:query_session_tests_result) {
      {'session'=> {'tests' => [{'status'=>'failed', 'test_name'=>'foo.rb'},
                                {'status'=>'error', 'test_name'=>'foo2.rb'},
                                {'status'=>'notstarted', 'test_name'=>'foo3.rb'},
                                {'status'=>'started', 'test_name'=>'foo4.rb'}]
                    },

        'non_passed_profile_name' => 'first'
      }
    }

    it "should produce a command line from an old session's results" do
      solano_api.should_receive(:query_session_tests).with(session_id).and_return(query_session_tests_result)
      Kernel.should_receive(:exec).with(/solano run --profile=first foo.rb foo2.rb foo3.rb foo4.rb/)

      subject.rerun(session_id)
    end

    it "should produce a command line from an last session's results" do
      solano_api.should_receive(:current_suite_id).exactly(3).times.and_return(123)
      solano_api.should_receive(:get_sessions).and_return([{"id" => 1234}])
      solano_api.should_receive(:query_session_tests).with(1234).and_return(query_session_tests_result)
      Kernel.should_receive(:exec).with(/solano run --profile=first foo.rb foo2.rb foo3.rb foo4.rb/)
      subject.rerun
    end
  end
end
