require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Invoice do
  before(:all) do
    @gl = GeneralLedger.create :name=>'Test GL'
    accts_recv = @gl.ledger_accounts.find(:first, :conditions=>{:ledger_type=>'AccountsReceivable'})
    accts_recv.should_not be_nil
    @invoiced_acct = accts_recv.subledger_accounts.create(:opening_balance=>Debit.new(0))
    @invoiced_acct.should_not be_nil
  end
  
  before(:each) do
    @valid_attributes = {
      :subledger_account => @invoiced_acct,
      :name => "value for name"
    }
  end

  it "should create a new instance given valid attributes" do
    lambda{Invoice.create(@valid_attributes)}.should change(Invoice, :count).by(1)
  end
  
  [:subledger_account, :name].each do |required_attr|
    it "should require a #{required_attr.to_s.humanize}" do
      @valid_attributes.delete required_attr
      lambda{Invoice.create(@valid_attributes)}.should_not change(Invoice, :count)    
    end
  end
  
  it "should begin in the open state" do
    @invoice = Invoice.create(@valid_attributes)
    @invoice.aasm_current_state.should eql(:open)
  end
  
  describe "in the open state" do
    before(:each) do
      @invoice = Invoice.create(@valid_attributes)
      assert_equal :open, @invoice.aasm_current_state
    end
    
    it "should not be able to close the invoice no details" do
      lambda{@invoice.close!}.should_not change(@invoice, :aasm_current_state)
    end
    
    [:total_due, :total_payments, :balance_due].each do |balance_mtd|
      it "should report the #{balance_mtd.to_s.humanize} as 0" do
        @invoice.send(balance_mtd).should eql(0)
      end
    end
  end
  
  describe "upon closing" do
    before(:each) do 
      @invoice = Invoice.create(:subledger_account=>@invoiced_acct, :name=>'Test invoice')
      lambda{
        @invoice.invoice_lines.create(:amount=>100.0, :name=>'Services')
        @invoice.invoice_lines.create(:amount=>150.0, :name=>'Widget')
      }.should change(InvoiceLine, :count).by(2)
    end
    
    it "should associate the invoice with a journal entry" do
      @invoice.close!
      @invoice.reload
      @invoice.journal_entry.should_not be_nil
    end
    
    it "should create an entry in the Sales Journal" do
      @sales = @gl.journals.find_by_journal_type("SalesJournal")
      target_count = @sales.journal_entries.count + 1
      lambda{@invoice.close!}.should change(@invoice, :aasm_current_state).from(:open).to(:closed)
      @sales.journal_entries.count.should eql(target_count)
    end
    
    it "should write two journal details with the transaction" do
      lambda{@invoice.close!}.should change(JournalDetail, :count).by(2)
    end
    
    it "should write a credit to the Sales Revenue account" do
      @revenue = @gl.ledger_accounts.find(:first, :conditions=>{:ledger_type=>"SalesRevenue"})
      target_count = @revenue.entries.count + 1
      @invoice.close!
      @revenue.entries.count.should eql(target_count)
      @revenue.entries.last.transaction_detail.balance_type.should == 'credit'
    end
    
    it "should write a debit to the AR subledger" do
      target_count = @invoiced_acct.entries.count + 1
      @invoice.close!
      @invoiced_acct.entries.count.should eql(target_count)
      @invoiced_acct.entries.last.transaction_detail.balance_type.should == 'debit'
    end
  end
  
  describe "in the closed state" do
    before(:each) do
      @invoice = Invoice.create(@valid_attributes)
      @invoice.invoice_lines.create(:amount=>100.0, :name=>'Services')
      @invoice.invoice_lines.create(:amount=>150.0, :name=>'Widget')
      @invoice.close!
    end

    describe "without payments" do
      it "should report the total balance due as the sum of the invoice lines" do
        @invoice.total_due.should eql(BigDecimal.new("250"))
      end
      
      it "should have a balance due matching the total due" do
        @invoice.balance_due.should eql(@invoice.total_due)
      end
      
      it "should report the total payments as 0" do
        @invoice.total_payments.should eql(0)
      end
    end
    
    describe "with payments" do
      before(:each) do
        @invoice.invoice_payments.create(:receipt=>mock_model(Receipt, :total_unallocated=>200), :amount=>50.0)
        @invoice.invoice_payments.create(:receipt=>mock_model(Receipt, :total_unallocated=>200), :amount=>50.0)
        @invoice.invoice_payments.count.should eql(2)
      end
      
      it "should report the total balance due as the sum of the invoice lines" do
        @invoice.total_due.should eql(BigDecimal.new("250"))
      end
      
      it "should report the total payments as the sum of the invoice payments" do
        @invoice.total_payments.should eql(BigDecimal.new("100"))
      end
      
      it "should have a balance due that is the difference between total due and total payments" do
        @invoice.balance_due.should eql(BigDecimal.new("150"))
      end
      
      it "should not be able to mark paid if there is a balance due" do
        lambda{@invoice.mark_paid!}.should_not change(@invoice, :aasm_current_state)
      end
      
      it "should transition to paid when a payment is applied that makes the balance due 0" do
        @invoice.invoice_payments.create(:receipt=>mock_model(Receipt, :total_unallocated=>200), :amount=>150)
        @invoice.reload
        @invoice.balance_due.should eql(0)
        @invoice.should be_paid
      end
    end
  end
end
