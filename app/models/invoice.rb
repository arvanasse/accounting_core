require 'transaction_detail'
class Invoice < ActiveRecord::Base
  belongs_to  :subledger_account
  
  belongs_to  :journal_entry
  delegate    'void!', :to=>:journal_entry
  
  has_many    :invoice_payments
  has_many    :invoice_lines
  
  validates_presence_of :name
  validates_numericality_of :subledger_account_id, 
                            :only_integer=>true, :greater_than=>0, 
                            :message=>'must be a valid reference'
  validates_numericality_of :journal_entry_id,
                            :only_integer=>true, :greater_than=>0, :allow_nil=>true,
                            :message =>'must be a valid reference'
  
  named_scope :by_date, :order=>"created_at DESC"
  
  include AASM
  aasm_column :status
  aasm_initial_state :open
    aasm_state :open
    aasm_state :closed, :enter => :record_in_journal
    aasm_state :paid
    
  aasm_event :close do
    transitions :from  => :open, :to => :closed, :guard => lambda{|invoice| invoice.invoice_lines.count>0}
  end
  
  aasm_event :mark_paid do
    transitions :from=>[:closed], :to=>:paid, :guard=>lambda{|invoice| invoice.balance_due==0}
  end
  
  def total_due
    return 0 if open?
    invoice_lines.sum(:amount)
  end
  
  def total_payments
    return 0 if open?
    invoice_payments.sum(:amount) || 0
  end
  
  def balance_due
    total_due - total_payments
  end
  
  private
  def record_in_journal
    gl = self.subledger_account.ledger_account.general_ledger
    sales_journal = gl.journals.find_by_journal_type('SalesJournal')
    sales_revenue = gl.ledger_accounts.find_by_ledger_type('SalesRevenue')
    
    if original_entry = create_journal_entry(:journal=>sales_journal, :description=>self.name)
      original_entry.journal_details.create(:account=>self.subledger_account, :transaction_detail=>Debit.new(total_due))
      original_entry.journal_details.create(:account=>sales_revenue, :transaction_detail=>Credit.new(total_due))
      original_entry.details_adjusted!
      original_entry.post! 
    end
    return original_entry
  end
end
