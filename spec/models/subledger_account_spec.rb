require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), 'account_behavior_spec')

describe SubledgerAccount do
  before(:each) do
    @account_class = SubledgerAccount
    @valid_attributes = {
       :ledger_account => mock_model(LedgerAccount)
    }
  end
  
  it "should require a ledger account" do
    @valid_attributes.delete(:ledger_account)
    lambda{@account = SubledgerAccount.create(@valid_attributes)}.should_not change(SubledgerAccount, :count)
    
  end

  it_should_behave_like "an account with entries"
  
  describe "with unposted entries" do
    fixtures :general_ledgers, :journals, :ledger_accounts
    before(:each) do
      @account = SubledgerAccount.create(
        :ledger_account => ledger_accounts(:koinonia_receivables), 
        :opening_balance=> Debit.new(100.00)
      )
      
      @change_in_balance = Debit.new(0.00)
      5.times do
        trans = Debit.new(50).credit(rand(100))
        @account.send(trans.balance_type, trans.amount)
        @change_in_balance = @change_in_balance.send(trans.balance_type, trans.amount)
      end
    end
    
    it "should be able to post the unposted entries" do
      lambda{@account.post_entries}.should change(@account.entries.unposted, :count).from(5).to(0)
    end
    
    it "should return the change in the reconciled balance when unposted entries are posted" do
      @account.post_entries.should == @change_in_balance
    end
    
    it "should change the reconciled balance to match the current balance when posting entries" do
      @account.post_entries
      @account.reconciled_balance.should == @change_in_balance.debit(100)
    end
  end
end
