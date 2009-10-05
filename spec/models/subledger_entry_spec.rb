require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), 'account_entry_behavior_spec')

describe SubledgerEntry do
  before(:each) do
    @valid_attributes = { :subledger_account  => mock_model(SubledgerAccount) }
  end
  
  it "should require a Subledger Account" do
    @valid_attributes.delete(:subledger_account)
    lambda{@account = SubledgerAccount.create(@valid_attributes)}.should_not change(SubledgerAccount, :count)
  end

  [Debit, Credit].each do |transaction_detail|
    describe "with a #{transaction_detail.name} transaction" do
      before(:each) do
        @valid_attributes[:transaction_detail] = transaction_detail.new(100)
        @entry_class = SubledgerEntry
      end
      
      it_should_behave_like "an account entry"
    end
  end
end
