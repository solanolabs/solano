# Copyright (c) 2011, 2012, 2013, 2014, 2015 Solano Labs All Rights Reserved

require 'spec_helper'
require 'solano/cli'
require 'solano/cli/commands/spec'

describe Solano::SolanoCli do
  describe "#describe" do
    include_context "solano_api_stubs"

    let(:session_id) { 123 }
    let(:query_session_tests_result) {
      {'session'=> {'tests' => [{'status'=>'failed', 'test_name'=>'foo.rb'}]}}
    }
    let(:suite_id) { 1 }
    let(:git_commit) { 'abcdef' }
    let(:get_sessions_result) {
      [{'id' => session_id, 'status' => 'passed', 'commit' => git_commit, 'start_time' => Time.now.utc.to_s, 'duration' => 1}]
    }

    it "should table print the failures" do
      solano_api.should_receive(:query_session_tests).with(session_id).and_return(query_session_tests_result)
      subject.should_receive(:print_table)
      subject.describe(session_id)
    end

    it "should print only names if indicated" do
      solano_api.should_receive(:query_session_tests).with(session_id).and_return(query_session_tests_result)
      subject.stub(:options) { { :names => true } }
      subject.should_receive(:say).with("foo.rb")
      subject.describe(session_id)
    end

    it "should exit with failure when no recent sessions exist on current branch" do
      solano_api.stub(:current_suite_id) { suite_id }
      subject.stub(:suite_for_current_branch?) { true }
      solano_api.stub(:get_sessions).exactly(1).times.and_return([])
      expect {
        subject.describe
      }.to raise_error(SystemExit,
                       /There are no recent sessions on this branch./)
    end

    it "should exit with failure when no suite exists on current branch" do
      solano_api.stub(:current_suite_id) { nil }
      solano_api.should_not_receive(:get_sessions)
      expect {
        subject.describe
      }.to raise_error(SystemExit,
                       /There are no recent sessions on this branch./)
    end

    context "prints recent session if no session id specified" do
      let(:scm) { double "Solano::Git" }

      before do
        solano_api.stub(:current_suite_id) { suite_id }
        subject.stub(:suite_for_current_branch?) { true }
        solano_api.stub(:get_sessions).exactly(1).times.and_return(get_sessions_result)
        solano_api.should_receive(:query_session_tests).with(session_id).and_return(query_session_tests_result)
        subject.should_receive(:print_table)
      end

      before(:each) do
        scm.stub(:repo?).and_return(true)
        scm.stub(:root).and_return(Dir.pwd)

        Solano::Git.stub(:new).and_return(scm)
      end

      it "should work for equal commits" do
        scm.should_receive(:current_commit).and_return(git_commit)
        subject.describe
      end

      it "should work when the worspace is ahead" do
        scm.should_receive(:current_commit).and_return("#{git_commit}1")
        scm.should_receive(:number_of_commits).and_return(1)
        subject.describe
      end

      it "should work when the worspace is behind" do
        scm.should_receive(:current_commit).and_return("#{git_commit}1")
        scm.should_receive(:number_of_commits).and_return(0, 1)
        subject.describe
      end
    end
  end
end
