# Copyright (c) 2011, 2012, 2013, 2014 Solano Labs All Rights Reserved

require 'spec_helper'
require 'msgpack_pure'
require 'solano/cli'
require 'solano/cli/commands/spec'

describe Solano::SolanoCli do
  include_context "solano_api_stubs"

  describe "#read_and_encode_config_file" do
    before(:each) do
      subject.send(:solano_setup, {:repo => true})
    end

    it "should return encoded config file" do
      dname = ".tddiumtesting"
      system("rm -rf #{dname}")
      system("mkdir #{dname}")
      Dir.chdir(dname) do
        expect(subject.send(:read_and_encode_config_file)).not_to be_nil
      end
      system("rm -rf #{dname}")
    end
  end

  describe "#spec" do
    let(:commit_log_parser) { double(GitCommitLogParser) }
    let(:suite_id) { 1 }
    let(:suite) {{ "repoman_current" => true }}
    let(:session) { { "id" => 1 } }
    let(:latest_commit) { "latest_commit" }
    let(:test_executions) { { "started" => 1, "tests" => [], "session_done" => true, "session_status" => "passed"}}
    let(:scm) { double "Solano::Git" }

    def stub_git
      allow(Solano::Git).to receive(:git_changes?).and_return(false)
      allow(Solano::Git).to receive(:git_push).and_return(true)
    end

    def stub_commit_log_parser
      allow(commit_log_parser).to receive(:commits).and_return([latest_commit])
      allow(GitCommitLogParser).to receive(:new).with(latest_commit).and_return(commit_log_parser)
    end

    before do
      stub_git
      stub_commit_log_parser
      allow(solano_api).to receive(:current_suite_id).and_return(suite_id)
      allow(solano_api).to receive(:get_suite_by_id).and_return(suite)
      allow(solano_api).to receive(:update_suite)
      allow(solano_api).to receive(:create_session).and_return(session)
      allow(solano_api).to receive(:register_session)
      allow(solano_api).to receive(:start_session).and_return(test_executions)
      allow(solano_api).to receive(:poll_session).and_return(test_executions)
      allow(solano_api).to receive(:get_keys).and_return([{name: 'some_key', pub: 'some content'}])
    end
 
    before(:each) do
      allow(scm).to receive(:repo?).and_return(true)
      allow(scm).to receive(:changes?).and_return(false)
      allow(scm).to receive(:root).and_return(Dir.pwd)
      allow(scm).to receive(:commits).and_return([latest_commit])
      allow(scm).to receive(:push_latest).and_return(true)
      allow(scm).to receive(:current_branch).and_return('current_branch')
      allow(scm).to receive(:origin_url).and_return('ssh://git@github.com/solano/solano.git')
      allow(scm).to receive(:ignore_path).and_return('.gitignore')

      allow(Solano::Git).to receive(:new).and_return(scm)
    end

    it "should create a new session" do
      commits_encoded = Base64.encode64(MessagePackPure.pack([latest_commit]))
      cache_paths_encoded = Base64.encode64(MessagePackPure.pack(nil))
      cache_control_encoded = Base64.encode64(MessagePackPure.pack(
        'Gemfile' => Digest::SHA1.file("Gemfile").to_s,
        'Gemfile.lock' => Digest::SHA1.file("Gemfile.lock").to_s,
        'solano.gemspec' => Digest::SHA1.file("solano.gemspec").to_s,
        'lib/solano/version.rb' => Digest::SHA1.file("lib/solano/version.rb").to_s,
      ))
      repo_config_file_encoded = Base64.encode64(File.read('config/solano.yml'))
      allow(solano_api).to receive(:get_suites).and_return([
        {"account" => "handle-2"},
      ])
      expect(solano_api).to receive(:create_session).with(suite_id, 
                                    :commits_encoded => commits_encoded,
                                    :cache_control_encoded => cache_control_encoded,
                                    :cache_save_paths_encoded => cache_paths_encoded,
                                    :raw_config_file => repo_config_file_encoded)
      allow(scm).to receive(:latest_commit).and_return(latest_commit)
      subject.spec
    end

    it "should not create a new session if a session_id is specified" do
      expect(solano_api).to_not receive(:create_session)
      expect(solano_api).to receive(:update_session)
      allow(solano_api).to receive(:get_suites).and_return([
        {"account" => "handle-2"},
      ])
      allow(scm).to receive(:latest_commit).and_return(latest_commit)
      allow(subject).to receive(:options) { {:session_id=>1} }
      subject.spec
    end

    it "should push to the public repo uri in CLI mode" do
      allow(subject).to receive(:options).and_return({:machine => false})
      allow(solano_api).to receive(:get_suites).and_return([
        {"account" => "handle-2"},
      ])
      allow(scm).to receive(:latest_commit).and_return(latest_commit)
      expect(scm).to receive(:push_latest).with(anything, anything, {}).and_return(true)
      subject.spec
    end

    it "should push to the private repo uri in ci mode" do
      allow(scm).to receive(:latest_commit).and_return(latest_commit)
      expect(scm).to receive(:push_latest).with(anything, anything, use_private_uri: true).and_return(true)
      allow(subject).to receive(:options).and_return({:machine => true})
      subject.spec
    end

    it "should set the profile if provided" do
      commits_encoded = Base64.encode64(MessagePackPure.pack([latest_commit]))
      cache_paths_encoded = Base64.encode64(MessagePackPure.pack(nil))
      cache_control_encoded = Base64.encode64(MessagePackPure.pack(
        'Gemfile' => Digest::SHA1.file("Gemfile").to_s,
        'Gemfile.lock' => Digest::SHA1.file("Gemfile.lock").to_s,
        'solano.gemspec' => Digest::SHA1.file("solano.gemspec").to_s,
        'lib/solano/version.rb' => Digest::SHA1.file("lib/solano/version.rb").to_s
      ))
      repo_config_file_encoded = Base64.encode64(File.read('config/solano.yml'))
      allow(solano_api).to receive(:get_suites).and_return([
        {"account" => "handle-2"},
      ])
      allow(subject).to receive(:options).and_return({:profile => "testing"})
      expect(solano_api).to receive(:create_session).with(suite_id, 
                                        :commits_encoded => commits_encoded,
                                        :cache_control_encoded => cache_control_encoded,
                                        :cache_save_paths_encoded => cache_paths_encoded,
                                        :raw_config_file => repo_config_file_encoded,
                                        :profile_name => "testing")
      allow(subject.scm).to receive(:latest_commit).and_return(latest_commit)
      subject.spec
    end
  end
end
