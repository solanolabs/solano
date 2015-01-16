# Copyright (c) 2015 Solano Labs All Rights Reserved

require 'spec_helper'
require 'solano/cli'
require 'solano/cli/commands/account'

describe Solano::SolanoCli do
  describe "#account" do
    include_context 'solano_api_stubs'

    let(:data) do
      { 'all_accounts' => [{ 
          "account_url"=>"http://localhost:3000/organizations/23/edit/profile",
          "billing_type"=>"recurly",
          "subscribed"=>false,
          "trial_remaining"=>0,
          "plan"=>"small",
          "heroku_needs_activation"=>false,
          "account"=>"some_name",
          "account_id"=>23,
          "account_role"=>"owner",
          "account_owner"=>"anyzhnik@solanolabs.com" 
        },
        { "account_url"=>"http://localhost:3000/organizations/20/edit/profile",
          "subscribed"=>false,
          "trial_remaining"=>0,
          "plan"=>"small",
          "heroku_needs_activation"=>false,
          "account"=>"some_other_name",
          "account_id"=>20,
          "account_role"=>"admin",
          "account_owner"=>"nyzhnikandrii@gmail.com"
        }] }
    end

    before do
      expect(subject).to receive(:solano_setup).with({ scm: false }).and_return(data)
      expect(solano_api).to receive(:get_suites).and_return([])
      expect(solano_api).to receive(:get_memberships).and_return([])
      expect(solano_api).to receive(:get_usage).and_return({})
      ERB.any_instance.stub(:result)
    end
  end
end
