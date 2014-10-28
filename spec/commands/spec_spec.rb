# Copyright (c) 2011, 2012, 2013, 2014 Solano Labs All Rights Reserved

require 'spec_helper'
require 'msgpack_pure'
require 'solano/cli'
require 'solano/cli/commands/spec'

describe Solano::SolanoCli do
  include_context "solano_api_stubs"

  describe "#read_and_encode_config_file" do
    it "should return encoded config file" do
      system("mkdir .tddiumtesting")
      Dir.chdir ".tddiumtesting"

      subject.send(:read_and_encode_config_file).should_not be_nil

      Dir.chdir ".."
      system("rm -rf .tddiumtesting")
    end
  end

  describe "#spec" do
    let(:commit_log_parser) { double(GitCommitLogParser) }
    let(:suite_id) { 1 }
    let(:suite) {{ "repoman_current" => true }}
    let(:session) { { "id" => 1 } }
    let(:latest_commit) { "latest_commit" }
    let(:test_executions) { { "started" => 1, "tests" => [], "session_done" => true, "session_status" => "passed"}}

    def stub_git
      Solano::Git.stub(:git_changes?).and_return(false)
      Solano::Git.stub(:git_push).and_return(true)
    end

    def stub_commit_log_parser
      commit_log_parser.stub(:commits).and_return([latest_commit])
      GitCommitLogParser.stub(:new).with(latest_commit).and_return(commit_log_parser)
    end

    before do
      stub_git
      stub_commit_log_parser
      solano_api.stub(:current_suite_id).and_return(suite_id)
      solano_api.stub(:get_suite_by_id).and_return(suite)
      solano_api.stub(:update_suite)
      solano_api.stub(:create_session).and_return(session)
      solano_api.stub(:register_session)
      solano_api.stub(:start_session).and_return(test_executions)
      solano_api.stub(:poll_session).and_return(test_executions)
      solano_api.stub(:get_keys).and_return([{name: 'some_key', pub: 'some content'}])
    end

    it "should create a new session" do
      commits_encoded = Base64.encode64(MessagePackPure.pack([latest_commit]))
      cache_paths_encoded = Base64.encode64(MessagePackPure.pack(nil))
      cache_control_encoded = Base64.encode64(MessagePackPure.pack(
        'Gemfile' => Digest::SHA1.file("Gemfile").to_s,
        'Gemfile.lock' => Digest::SHA1.file("Gemfile.lock").to_s,
      ))
      repo_config_file_encoded = Base64.encode64(File.read('config/solano.yml'))
      solano_api.stub(:get_suites).and_return([
        {"account" => "handle-2"},
      ])
      solano_api.should_receive(:create_session).with(suite_id, 
                                        :commits_encoded => commits_encoded,
                                        :cache_control_encoded => cache_control_encoded,
                                        :cache_save_paths_encoded => cache_paths_encoded,
                                        :raw_config_file => repo_config_file_encoded)
      subject.scm.stub(:latest_commit).and_return(latest_commit)
      subject.spec
    end

    it "should not create a new session if a session_id is specified" do
      solano_api.should_not_receive(:create_session)
      solano_api.should_receive(:update_session)
      solano_api.stub(:get_suites).and_return([
        {"account" => "handle-2"},
      ])
      subject.stub(:options) { {:session_id=>1} }
      subject.scm.stub(:latest_commit).and_return(latest_commit)
      subject.spec
    end

    it "should push to the public repo uri in CLI mode" do
      subject.stub(:options) { {:machine => false} }
      tddium_api.stub(:get_suites).and_return([
        {"account" => "handle-2"},
      ])
      subject.scm.stub(:latest_commit).and_return(latest_commit)
      subject.scm.should_receive(:push_latest).with(anything, anything, {}).and_return(true)
      subject.spec
    end

    it "should push to the private repo uri in ci mode" do
      subject.stub(:options) { {:machine => true} }
      subject.scm.stub(:latest_commit).and_return(latest_commit)
      subject.scm.should_receive(:push_latest).with(anything, anything, use_private_uri: true).and_return(true)
      subject.spec
    end
  end
end
