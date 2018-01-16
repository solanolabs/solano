# Copyright (c) 2011, 2012, 2013, 2014, 2017 Solano Labs All Rights Reserved

require 'spec_helper'
require 'solano/cli'
require 'solano/cli/commands/status'

describe Solano::SolanoCli do
  include_context "solano_api_stubs"

  describe "#status" do
    let(:suite_id) { 1 }

    # TODO: this test stops execution of others
    # When it runs in a batch - all tests in a batch marked as skipped!
    # Story https://jira.slno.net/jira/browse/CICLI-103
    xit "should display current status with no suites or sessions" do
      solano_api.should_receive(:get_suites).once.and_return([])
      subject.should_receive(:suite_for_current_branch?).and_return(false)
      subject.should_receive(:suite_for_default_branch?).and_return(false)
      solano_api.should_receive(:get_sessions).once.and_return([])
      subject.status
    end

    context "with suite and valid current branch" do
      before do
        subject.stub(:suite_for_current_branch?) { true }
        solano_api.stub(:current_suite_id) { suite_id }
        solano_api.stub(:current_branch) { "branch" }
        solano_api.stub(:get_suites) { [{ 'account' => 'org1', 'id' => 99999 }] }
      end

      it "should display current status with no sessions" do
        solano_api.should_receive(:get_sessions).exactly(2).times.and_return([])
        subject.status
      end

      it "should display current status as JSON with no sessions" do
        solano_api.should_receive(:get_sessions).exactly(2).times.and_return([])
        subject.stub(:options) { {:json => true } }
        subject.status
      end

      it "should display current status as valid JSON" do
        solano_api.should_receive(:get_sessions).exactly(2).times.and_return([])
        subject.should_receive(:puts).with(/running|history/i)
        subject.should_not_receive(:puts).with(/Re-run failures from a session with/i)
        subject.stub(:options) { {:json => true } }
        subject.status
      end
    end

    context "with suite, invalid current and valid default branches" do
      before do
        subject.stub(:suite_for_current_branch?) { false }
        subject.stub(:suite_for_default_branch?) { true }
        solano_api.stub(:default_suite_id) { suite_id }
        solano_api.stub(:default_branch) { "branch" }
        solano_api.stub(:get_suites) { [{ 'account' => 'org1', 'id' => 99999 }] }
      end

      it "should display current status with no sessions" do
        solano_api.should_receive(:get_sessions).exactly(2).times.and_return([])
        subject.status
      end

      it "should display current status as JSON with no sessions" do
        solano_api.should_receive(:get_sessions).exactly(2).times.and_return([])
        subject.stub(:options) { {:json => true } }
        subject.status
      end

      it "should display current status as valid JSON" do
        solano_api.should_receive(:get_sessions).exactly(2).times.and_return([])
        subject.should_receive(:puts).with(/running|history/i)
        subject.should_not_receive(:puts).with(/Re-run failures from a session with/i)
        subject.stub(:options) { {:json => true } }
        subject.status
      end
    end
  end

  describe "#show_session_details" do
    let(:branch) { false }
    let(:output) { subject.send(:capture_stdout) { subject.send(:show_session_details, "xxx", {:suite_id => 1}, "X", "Y-%s-", branch) } }

    before(:each) do
      subject.send(:solano_setup)
    end

    it "shows empty" do
      expect(solano_api).to receive(:get_sessions).once.and_return([])
      output = subject.send(:capture_stdout) { subject.send(:show_session_details, "xxx", {}, "X", "Y", false) }
      expect(output).to eq "\nX\n"
    end

    context "with a session" do
      let(:session) {{
        "commit" => "12345671234567",
        "id" => "111",
        "status" => "running",
        "duration" => 123,
        "start_time" => Time.now.to_s,
        "branch" => "foo/bar"
      }}

      before do
        now = Time.now
        expect(Time).to receive(:now).at_least(:once).and_return Time.at(now.to_i)
        expect(solano_api).to receive(:get_sessions).once.and_return([session])
      end

      it "shows normal" do
        expect(output).to eq "\nY-xxx-\n\nSession #  Commit   Status   Duration  Started\n---------  ------   ------   --------  -------\n111        1234567  running  123s      0 secs ago\n"
      end

      context "with branch" do
        let(:branch) { true }

        it "shows normal" do
          expect(output).to eq "\nY-xxx-\n\nSession #  Commit   Branch   Status   Duration  Started\n---------  ------   ------   ------   --------  -------\n111        1234567  foo/bar  running  123s      0 secs ago\n"
        end
      end

      it "shows current head" do
        expect_any_instance_of(Solano::Git).to receive(:current_commit).and_return session["commit"]
        expect(output).to eq "\nY-xxx-\n\nSession #  Commit   Status   Duration  Started\n---------  ------   ------   --------  -------\n111        \e[7m1234567\e[0m  running  123s      0 secs ago\n"
      end
    end
  end
end
