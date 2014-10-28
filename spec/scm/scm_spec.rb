# Copyright (c) 2014 Solano Labs All Rights Reserved

require 'spec_helper'
require 'solano/scm/scm'
require 'solano/scm/git'
require 'solano/scm/hg'
require 'solano/constant'

describe Solano::SCM do
  include SolanoConstant
  
  describe '.configure' do
    context 'for git repo' do
      let(:solano_git) { double(Solano::Git).as_null_object }

      context 'when git is installed' do
        it "doesn't abort" do
          Solano::Git.any_instance.should_receive(:repo?).and_return true
          Solano::Git.stub(:`).with('git --version').and_return 'git version 1.9.3 (Apple Git-50)'
          Solano::Git.should_receive(:new).and_call_original
          Solano::Hg.should_not_receive(:new)

          expect{ Solano::SCM.configure }.not_to raise_error
        end

        it 'returns correct SCM instance' do
          Solano::Git.should_receive(:new).and_return solano_git
          solano_git.should_receive(:repo?).and_return true
          solano_git.class.stub(:version_ok)
          Solano::Git.stub(:`).with('git --version').and_return 'git version 1.9.3 (Apple Git-50)'
          Solano::Hg.should_not_receive(:new)

          expect(Solano::SCM.configure).to eq(solano_git)
        end
      end

      context 'when git is not installed' do
        it 'aborts with message' do
          Solano::Git.should_receive(:new).and_call_original
          Solano::Git.any_instance.should_receive(:repo?).and_return true
          Solano::Git.stub(:`).with('git --version').and_raise Exception
          Solano::Hg.should_not_receive(:new)

          expect{
            Solano::SCM.configure
          }.to raise_error(SystemExit, self.class::Text::Error::SCM_NOT_FOUND)
        end
      end
    end

    context 'for mercurial repo' do
      context 'when mercurial is installed' do
        let(:solano_hg) { double(Solano::Hg).as_null_object }

        it "doesn't abort" do
          Solano::Git.any_instance.should_receive(:repo?).and_return false
          Solano::Git.any_instance.should_not_receive(:version_ok)

          Solano::Hg.should_receive(:new).and_call_original
          Solano::Hg.any_instance.should_receive(:repo?).and_return true
          Solano::Hg.stub(:`).with('hg -q --version').and_return 'Mercurial Distributed SCM (version 3.1.1)'

          expect{
            Solano::SCM.configure
          }.not_to raise_error
        end

        it 'returns correct SCM instance' do
          Solano::Git.any_instance.should_receive(:repo?).and_return false
          Solano::Git.any_instance.should_not_receive(:version_ok)

          Solano::Hg.stub(:`).with('hg -q --version').and_return 'Mercurial Distributed SCM (version 3.1.1)'
          Solano::Hg.stub(:new).and_return solano_hg
          solano_hg.should_receive(:repo?).and_return true
          solano_hg.class.stub(:version_ok)
          
          expect(Solano::SCM.configure).to eq(solano_hg)
        end
      end

      context 'when mercurial is not installed' do
        it 'abort with message' do
          Solano::Git.any_instance.should_receive(:repo?).and_return false
          Solano::Git.any_instance.should_not_receive(:version_ok)

          Solano::Hg.should_receive(:new).and_call_original
          Solano::Hg.any_instance.should_receive(:repo?).and_return true
          Solano::Hg.stub(:`).with('hg -q --version').and_raise(Exception)

          expect{
            Solano::SCM.configure
          }.to raise_error(SystemExit, self.class::Text::Error::SCM_NOT_FOUND)
        end
      end
    end

    context 'for non git and non mercurial repo' do
      let(:solano_git) { double(Solano::Git).as_null_object }

      it 'returns git scm' do
        Solano::Git.stub(:new).and_return solano_git
        solano_git.should_receive(:repo?).and_return false
        solano_git.class.stub(:version_ok)
        Solano::Hg.any_instance.should_receive(:repo?).and_return false

        expect(Solano::SCM.configure).to eq(solano_git)
      end
    end
  end
end
