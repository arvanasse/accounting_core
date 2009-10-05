require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), 'account_behavior_spec')

describe LedgerAccount do
  before(:each) do
    @account_class = LedgerAccount
    @valid_attributes = {
      :general_ledger => mock_model(GeneralLedger),
      :opening_balance => Debit.new(100),
      :name => "Cash",
      :account_number => 0,
      :ledger_type => "Cash"
    }
  end

  [:name, :account_number, :ledger_type].each do |required_attr|
    it "should require a #{required_attr}" do
      @valid_attributes.delete(required_attr)
      lambda{@account = LedgerAccount.create @valid_attributes}.should_not change(LedgerAccount, :count)
    end
  end
  
  it "should require a General Ledger" do
    @valid_attributes.delete(:general_ledger)
      lambda{@account = LedgerAccount.create @valid_attributes}.should_not change(LedgerAccount, :count)
  end
  
  it_should_behave_like "an account with entries"
end
