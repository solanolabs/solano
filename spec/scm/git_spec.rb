# Copyright (c) 2011, 2012, 2013, 2014 Solano Labs All Rights Reserved

require 'spec_helper'
require 'solano/scm/git'

describe Solano::Git do
  let(:subject) { Solano::Git.new }

  def stub_git(command, return_value)
    subject.stub(:`).with(/^git #{command}/).and_return(return_value)
  end

  describe ".latest_commit" do
    before do
      stub_git("log", "latest_commit")
    end

    it "should return the latest commit" do
      subject.should_receive(:`).with("git log --pretty='%H%n%s%n%aN%n%aE%n%at%n%cN%n%cE%n%ct%n' -1")
      subject.send(:latest_commit).should == "latest_commit"
    end
  end

  module Solano
    class Git
      def say(message)
        puts message
      end
    end
  end

  describe ".offer_snapshot_creation" do
    before do
      stub_const("Solano::Git::Text::Process::ASK_FOR_SNAPSHOT", "")
      stub_const("Solano::Git::Text::Error::ANSWER_NOT_Y", "NOT Y")
    end

    it "should create a snapshot if given Y" do
      expect(STDIN).to receive(:gets).and_return('Y')
      expect(subject).to receive(:create_snapshot).and_return(true)
      subject.offer_snapshot_creation(123)
    end

    it "should raise an error if given n" do
      expect(STDIN).to receive(:gets).and_return('n')
      expect(subject).to_not receive(:create_snapshot)
      expect{
        subject.offer_snapshot_creation(123)
      }.to raise_error(RuntimeError)
    end

    it "should raise an error if given anything besides Y" do
      expect(STDIN).to receive(:gets).and_return('asdas')
      expect(subject).to_not receive(:create_snapshot)
      expect{
        subject.offer_snapshot_creation(123)
      }.to raise_error(RuntimeError)

    end
  end
end
