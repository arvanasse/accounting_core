require 'transaction_detail'
class Receipt < ActiveRecord::Base
  belongs_to  :subledger_account
  
  belongs_to  :journal_entry
  delegate    'void!', :to=>:journal_entry
  
  has_many    :invoice_payments
  has_many    :receipt_details
  
  validates_numericality_of :subledger_account_id,
                            :only_integer=>true, :greater_than=>0,
                            :message =>'must be a valid reference'
  validates_numericality_of :journal_entry_id,
                            :only_integer=>true, :greater_than=>0, :allow_nil=>true,
                            :message =>'must be a valid reference'
                          
  named_scope :by_date, :order=>"created_at DESC"
                          
  include AASM
  aasm_column :status
  aasm_initial_state :open
    aasm_state :open
    aasm_state :closed, :enter => :record_in_journal
    aasm_state :posted
    
  aasm_event :close do
    transitions :from=>:open, :to=>:closed, :guard=>lambda{|receipt| receipt.receipt_details.count>0}
  end
  
  aasm_event :post do
    transitions :from=>:closed, :to=>:posted
  end
  
  def total_paid
    return 0 if open?
    receipt_details.sum(:amount) || 0
  end
  
  def total_allocated
    return 0 if open?
    invoice_payments.sum(:amount) || 0
  end
  
  def total_unallocated
    total_paid - total_allocated
  end
  
  private
  def record_in_journal
    gl = self.subledger_account.ledger_account.general_ledger
    cash_receipts = gl.journals.find_by_journal_type('CashReceiptsJournal')
    cash          = gl.ledger_accounts.find_by_ledger_type('Cash')
    
    if original_entry = create_journal_entry(:journal=>cash_receipts, :description=>"Payment for #{self.subledger_account.uuid}")
      original_entry.journal_details.create(:account=>self.subledger_account, :transaction_detail=>Credit.new(total_paid))
      original_entry.journal_details.create(:account=>cash, :transaction_detail=>Debit.new(total_paid))
      original_entry.details_adjusted!
      original_entry.post! 
    end
    return original_entry
  end
end
