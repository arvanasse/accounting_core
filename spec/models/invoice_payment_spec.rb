require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InvoicePayment do
  before(:all) do
    @gl = GeneralLedger.create :name=>'Test GL'
    accts_recv = @gl.ledger_accounts.find(:first, :conditions=>{:ledger_type=>'AccountsReceivable'})
    accts_recv.should_not be_nil
    @invoiced_acct = accts_recv.subledger_accounts.create(:opening_balance=>Debit.new(0))
    @invoiced_acct.should_not be_nil
  end
  
  before(:each) do
    @valid_attributes = {
      :invoice => mock_model(Invoice, 'paid?'=>false,  'closed?'=>true, :balance_due=>1),
      :receipt => mock_model(Receipt, :total_unallocated=>200), 
      :amount  => 25
    }
  end

  it "should create a new instance given valid attributes" do
    lambda{InvoicePayment.create(@valid_attributes)}.should change(InvoicePayment, :count).by(1)
  end
  
  [:invoice, :receipt, :amount].each do |required_assoc|
    it "should require a #{required_assoc}" do
      @valid_attributes.delete required_assoc
      lambda{InvoicePayment.create(@valid_attributes)}.should_not change(InvoicePayment, :count)
    end
  end
  
  it "should not be able to apply payment to an invoice that is paid in full" do
    @valid_attributes[:invoice] = mock_model(Invoice, 'paid?'=>true)
    lambda{InvoicePayment.create(@valid_attributes)}.should_not change(InvoicePayment, :count)
  end
  
  it "should mark the invoice paid if it brings the balance due to 0" do
    invoice = Invoice.create(:name=>'test', :subledger_account=>@invoiced_acct)
    invoice.invoice_lines << InvoiceLine.new(:name=>'widget', :amount=>50)
    invoice.save
    invoice.close!
    lambda{
      invoice.invoice_payments.create(:receipt=>mock_model(Receipt, :total_unallocated=>50), :amount=>50)
      invoice.reload
    }.should change(invoice, :aasm_current_state).from(:closed).to(:paid)
  end
end
