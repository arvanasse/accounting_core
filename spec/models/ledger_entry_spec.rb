require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), 'account_entry_behavior_spec')

describe LedgerEntry do
  before(:each) do
    @valid_attributes = { :ledger_account => mock_model(LedgerAccount) }
  end
  
  it "should require a Ledger Account" do
    @valid_attributes.delete(:ledger_account)
    lambda{@account = LedgerAccount.create(@valid_attributes)}.should_not change(LedgerAccount, :count)
  end

  [Debit, Credit].each do |transaction_detail|
    describe "with a #{transaction_detail.name} transaction" do
      before(:each) do
        @valid_attributes[:transaction_detail] = transaction_detail.new(100)
        @entry_class = LedgerEntry
      end
      
      it_should_behave_like "an account entry"
    end
  end
end
