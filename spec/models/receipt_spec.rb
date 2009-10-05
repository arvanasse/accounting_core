require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Receipt do
  before(:all) do
    @gl = GeneralLedger.create :name=>'Test GL'
    accts_recv = @gl.ledger_accounts.find(:first, :conditions=>{:ledger_type=>'AccountsReceivable'})
    accts_recv.should_not be_nil
    @invoiced_acct = accts_recv.subledger_accounts.create(:opening_balance=>Debit.new(0))
    @invoiced_acct.should_not be_nil

    @cash = PaymentInstrument.find(:first, :conditions=>{:name=>'Cash'})
    @check = PaymentInstrument.find(:first, :conditions=>{:name=>'Check'})
  end
  
  before(:each) do
    @valid_attributes = {
      :subledger_account => @invoiced_acct
    }
  end

  it "should create a new instance given valid attributes" do
    lambda{Receipt.create(@valid_attributes)}.should change(Receipt, :count).by(1)
  end
  
  it "should require a subledger account" do
    @valid_attributes.delete :subledger_account
    lambda{Receipt.create(@valid_attributes)}.should_not change(Receipt, :count)
  end
  
  describe 'after creation' do
    before(:each) do
      @receipt = Receipt.create(@valid_attributes)
    end
    
    it "should enter the open state" do
      @receipt.should be_open
    end
    
    it "should not transition to the closed state without receipt details" do
      lambda{@receipt.close!}.should_not change(@receipt, :aasm_current_state)
    end
    
    describe 'with receipt details' do
      before(:each) do
        lambda{
          @receipt.receipt_details << ReceiptDetail.new(:amount=>50, :payment_instrument_id=>@cash.id)
          @receipt.receipt_details << ReceiptDetail.new(:amount=>50, :payment_instrument_id=>@check.id, :reference_number=>1234)
        }.should change(ReceiptDetail, :count).by(2)
      end
      
      it "should be able to transition to the closed state" do
        @receipt.close!
        @receipt.should be_closed
      end
    end
  end
  
  describe "upon closing" do
    before(:each) do 
      @receipt = Receipt.create(:subledger_account=>@invoiced_acct)
      lambda{
        @receipt.receipt_details.create(:amount=>100.0, :payment_instrument_id=>@cash.id)
        @receipt.receipt_details.create(:amount=>150.0, :payment_instrument_id=>@check.id, :reference_number=>1234)
      }.should change(ReceiptDetail, :count).by(2)
    end
    
    it "should associate the receipt with a journal entry" do
      @receipt.close!
      @receipt.reload
      @receipt.journal_entry.should_not be_nil
    end
    
    it "should create an entry in the Cash Receipts Journal" do
      @cash_receipts = @gl.journals.find_by_journal_type("CashReceiptsJournal")
      target_count = @cash_receipts.journal_entries.count + 1
      lambda{@receipt.close!}.should change(@receipt, :aasm_current_state).from(:open).to(:closed)
      @cash_receipts.journal_entries.count.should eql(target_count)
    end
    
    it "should write two journal details with the transaction" do
      lambda{@receipt.close!}.should change(JournalDetail, :count).by(2)
    end
    
    it "should write a debit to the Cash account" do
      @revenue = @gl.ledger_accounts.find(:first, :conditions=>{:ledger_type=>"Cash"})
      target_count = @revenue.entries.count + 1
      @receipt.close!
      @revenue.entries.count.should eql(target_count)
      @revenue.entries.last.transaction_detail.balance_type.should == "debit"
    end
    
    it "should write a credit to the AR subledger" do
      target_count = @invoiced_acct.entries.count + 1
      @receipt.close!
      @invoiced_acct.entries.count.should eql(target_count)
      @invoiced_acct.entries.last.transaction_detail.balance_type.should == "credit"
    end
  end

  describe "in the closed state" do
    before(:each) do
      @receipt = Receipt.create(@valid_attributes)
      @cash = PaymentInstrument.find(:first, :conditions=>{:name=>'Cash'})
      @check = PaymentInstrument.find(:first, :conditions=>{:name=>'Check'})
      @receipt.receipt_details << ReceiptDetail.new(:amount=>50, :payment_instrument_id=>@cash.id)
      @receipt.receipt_details << ReceiptDetail.new(:amount=>50, :payment_instrument_id=>@check.id, :reference_number=>1234)
      @receipt.close!
      @receipt.should be_closed
    end
    
    it "should report the total paid as the sum of the detail amounts" do
      @receipt.total_paid.should eql(BigDecimal.new('100'))
    end

    describe "without assignment to invoices" do
      it "should report the total allocated as 0" do
        @receipt.total_allocated.should ==(BigDecimal.new('0'))
      end
      
      it "should report the total unallocated matching th total paid" do
        @receipt.total_unallocated.should eql(@receipt.total_paid)
      end
    end
    
    describe "with assignments to invoices" do
      before(:each) do
        lambda{
          ip = @receipt.invoice_payments.create(:amount=>25, :invoice=>mock_model(Invoice, 'paid?'=>false, 'closed?'=>true, :balance_due=>100))
          ip = @receipt.invoice_payments.create(:amount=>50, :invoice=>mock_model(Invoice, 'paid?'=>false, 'closed?'=>true, :balance_due=>100))
        }.should change(InvoicePayment, :count).by(2)
      end
      
      it "should report the total allocated as the sum of the invoice payments" do
        @receipt.total_allocated.should ==(BigDecimal.new('75'))
      end
      
      it "should report the total unallocated as the difference between total paid and total allocated" do
        @receipt.total_unallocated.should ==(BigDecimal.new('25'))
      end
      
      it "should not allow an invoice assignment that exceeds the total unallocated amount" do
        lambda{
          @receipt.invoice_payments.create(:invoice=>mock_model(Invoice, 'paid?'=>false, 'closed?'=>true, :balance_due=>100), :amount=>50)
        }.should_not change(InvoicePayment, :count)
      end
    end
  end
end
