class InvoicePayment < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :receipt
  
  validates_numericality_of :invoice_id, :receipt_id, 
                            :only_integer=>true, :greater_than=>0, 
                            :message=>'must be supplied'
  validates_numericality_of :amount, :greater_than_or_equal_to=>0
                          
  protected
  def validate
    errors.add_to_base("Cannot apply payment to an invoice that is paid in full.") if self.invoice && self.invoice.paid?
    if self.receipt && self.amount && self.amount > self.receipt.total_unallocated
      errors.add(:amount, "Cannot exceed the total unallocated amount of the receipt") 
    end
  end
end
