# Copyright (c) 2011, 2012, 2013, 2014 Solano Labs All Rights Reserved

require 'spec_helper'
require 'tddium_client'
require 'solano/cli/api'
require 'solano/cli/config'
require 'net/http'

describe Solano::SolanoAPI do
  let(:scm) { scm_config = Solano::SCM.configure; scm_config[0] }
  let(:api_config) { double(Solano::ApiConfig, :get_branch => nil) }
  let(:tddium_client) { double(TddiumClient::Client) }
  let(:subject) { Solano::SolanoAPI.new(scm, tddium_client, api_config) }

  shared_examples_for "retrieving the branch info" do
    before do
      scm.stub(:current_branch).and_return("master")
      api_config.stub(:get_branch).with("master", key, anything()).and_return(key)
    end

    it "should return the branch info" do
      subject.send(method).should == key
    end
  end

  describe "#current_suite_id" do
    it_should_behave_like "retrieving the branch info" do
      let(:method) { :current_suite_id }
      let(:key) { "id" }
    end
  end

  describe "#current_suite_options" do
    it_should_behave_like "retrieving the branch info" do
      let(:method) { :current_suite_options }
      let(:key) { "options" }
    end
  end

  describe "#create_session(suite_id, params = {})" do
    before do
      api_config.stub(:get_api_key)
      tddium_client.stub(:call_api).and_return({"session" => "session_json"})
    end

    it "should post to /sessions" do
      tddium_client.should_receive(:call_api).with(:post, "sessions", {:suite_id => 1, :commits => ["foo"]}, nil)
      subject.create_session(1, :commits => ["foo"]).should == ["session_json", nil]
    end
  end

  describe "#user_logged_in?" do
    before do
      api_config.stub(:get_api_key)
      subject.stub(:say)
    end

    let(:global_api_key) { "global_api_key" }
    let(:repo_api_key) { "repo_api_key" }

    context "where the global api key is set" do
      before do
        api_config.stub(:get_api_key).with(:global => true).and_return(global_api_key)
      end

      context "but the repos api key is missing" do
        before do
          api_config.stub(:get_api_key).with(:repo => true).and_return(nil)
        end

        it "should return the global api key" do
          subject.user_logged_in?(false, false).should == global_api_key
        end
      end

      context "and the repos api key is the same as the global api key" do
        before do
          api_config.stub(:get_api_key).with(:repo => true).and_return(global_api_key)
        end

        it "should return the repo api key" do
          subject.user_logged_in?(false, false).should == global_api_key
        end
      end

      context "but the repos api key is different from the global api key" do
        before do
          api_config.stub(:get_api_key).with(:repo => true).and_return(repo_api_key)
        end

        it "should return nil" do
          subject.should_not_receive(:say)
          subject.user_logged_in?(false, false).should be_nil
        end

        context "with args false, true" do
          it "should print a message saying the users credentials are invalid" do
            subject.should_receive(:say).with(
              "Your .solano file has an invalid API key.\nRun `solano logout` and `solano login`, and then try again."
            )
            subject.user_logged_in?(false, true)
          end
        end
      end
    end
  end

  context "#get_user" do
    before do
      api_config.stub(:get_api_key)
      tddium_client.stub(:call_api) { raise SocketError }
    end

    it "not returns nil when call_api raise an error" do
      expect { subject.get_user }.to raise_error
    end
  end

  EXAMPLE_HTTP_METHOD = :post
  EXAMPLE_TDDIUM_RESOURCE = "suites"

  context "handle call_api upgrade exceptions" do
    before do
      api_config.stub(:get_api_key)
      http_response = Net::HTTPResponse.new(1.0, '426', "failed")
      http_response.stub_chain(:body).and_return({:explanation => "upgrade require error"}.to_json)
      tddium_client.stub(:call_api).and_raise(TddiumClient::Error::UpgradeRequired.new(http_response))
    end

    it "should handle TddiumClient::Error::UpgradeRequired exception and recieve error message" do
      expect { subject.call_api(EXAMPLE_HTTP_METHOD, EXAMPLE_TDDIUM_RESOURCE) }.to raise_error("API Error: upgrade require error")
    end
  end

  context "handle call_api cert exceptions" do
    before do
      api_config.stub(:get_api_key)
      tddium_client.stub(:call_api).and_raise(TddiumClient::Error::APICert.new("error message"))
    end

    it "should handle TddiumClient::Error::APICert exception and recieve error message" do
      expect { subject.call_api(EXAMPLE_HTTP_METHOD, EXAMPLE_TDDIUM_RESOURCE) }.to raise_error("API Cert Error: error message")
    end
  end

  context "handle call_api base exceptions" do
    before do
      api_config.stub(:get_api_key)
      http_response = Net::HTTPResponse.new(1.0, '503', "failed")
      http_response.stub_chain(:header, :reason_phrase).and_return("server error")
      tddium_client.stub(:call_api).and_raise(TddiumClient::Error::Server.new(http_response))
      subject.stub(:say)
    end

    it "should handle TddiumClient::Error::Base exception and recieve error message" do
      expect { subject.call_api(EXAMPLE_HTTP_METHOD, EXAMPLE_TDDIUM_RESOURCE) }.to raise_error {|error| error.should be_a(TddiumClient::Error::Base)}
    end
  end

end
