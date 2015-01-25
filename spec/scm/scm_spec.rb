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
          expect_any_instance_of(Solano::Git).to receive(:repo?).and_return(true)
          expect(Solano::Git).to receive(:`).with('git --version').and_return 'git version 1.9.3 (Apple Git-50)'
          expect(Solano::Git).to receive(:new).and_call_original
          expect(Solano::Hg).not_to receive(:new)

          expect{ Solano::SCM.configure }.not_to raise_error
        end

        it 'returns correct SCM instance' do
          expect(Solano::Git).to receive(:new).and_return solano_git
          expect(solano_git).to receive(:repo?).and_return(true)
          allow(solano_git.class).to receive(:version_ok)
          expect(Solano::Git).to receive(:`).with('git --version').and_return 'git version 1.9.3 (Apple Git-50)'
          expect(Solano::Hg).not_to receive(:new)

          expect(Solano::SCM.configure).to eq([solano_git, true])
        end
      end

      context 'when git is not installed' do
        it 'aborts with message' do
          expect(Solano::Git).to receive(:new).twice.and_call_original
          expect_any_instance_of(Solano::Git).to receive(:repo?).and_return(true)
          expect(Solano::Git).to receive(:`).twice.with('git --version').and_raise(Exception)
          expect(Solano::Hg).to receive(:new).twice.and_call_original
          expect(Solano::Hg).to receive(:`).with('hg -q --version').and_raise(Exception)

          scm, ok = Solano::SCM.configure
          expect(ok).to eq(false)
        end
      end
    end

    context 'for mercurial repo' do
      context 'when mercurial is installed' do
        let(:solano_hg) { double(Solano::Hg).as_null_object }

        it "doesn't abort" do
          expect_any_instance_of(Solano::Git).to receive(:repo?).and_return(false)
          expect(Solano::Git).not_to receive(:version_ok)

          expect(Solano::Hg).to receive(:new).and_call_original
          expect_any_instance_of(Solano::Hg).to receive(:repo?).and_return(true)
          expect(Solano::Hg).to receive(:`).with('hg -q --version').and_return('Mercurial Distributed SCM (version 3.1.1)')

          expect{
            Solano::SCM.configure
          }.not_to raise_error
        end

        it 'returns correct SCM instance' do
          expect_any_instance_of(Solano::Git).to receive(:repo?).and_return(false)
          expect(Solano::Git).not_to receive(:version_ok)

          expect(Solano::Hg).to receive(:`).with('hg -q --version').and_return('Mercurial Distributed SCM (version 3.1.1)')
          expect(Solano::Hg).to receive(:new).and_return solano_hg
          expect(solano_hg).to receive(:repo?).and_return(true)
          allow(solano_hg.class).to receive(:version_ok)
          
          expect(Solano::SCM.configure).to eq([solano_hg, true])
        end
      end

      context 'when mercurial is not installed' do
        it 'abort with message' do
          expect_any_instance_of(Solano::Git).to receive(:repo?).and_return(false)
          expect(Solano::Git).to receive(:version_ok).and_return(false)

          expect_any_instance_of(Solano::Hg).to receive(:repo?).and_return(false)
          expect(Solano::Hg).to receive(:`).with('hg -q --version').and_raise(Exception)


          scm, ok = Solano::SCM.configure
          expect(ok).to eq(false)
        end
      end
    end

    context 'for non git and non mercurial repo' do
      let(:solano_hg) { double(Solano::Hg).as_null_object }
      let(:solano_git) { double(Solano::Git).as_null_object }
      let(:solano_stub_scm) { double(Solano::StubSCM).as_null_object }

      it 'returns generic scm' do
        expect(Solano::StubSCM).to receive(:new).and_return solano_stub_scm

        expect(Solano::Git).to receive(:new).twice.and_return solano_git
        expect(solano_git).to receive(:repo?).and_return(false)
        expect(Solano::Git).to receive(:version_ok).and_return(false)

        expect(Solano::Hg).to receive(:new).twice.and_return solano_hg
        expect(solano_hg).to receive(:repo?).and_return(false)
        expect(Solano::Hg).to receive(:version_ok).and_return(false)

        expect(Solano::SCM.configure).to eq([solano_stub_scm, false])
      end
    end
  end
end
