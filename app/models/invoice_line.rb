class InvoiceLine < ActiveRecord::Base
  belongs_to  :invoice
  
  validates_numericality_of :invoice_id, 
                            :only_integer=>true, :greater_than=>0, :on=>:update,
                            :message=>'must be a valid reference'
  validates_presence_of     :name
  validates_numericality_of :amount, :greater_than_or_equal_to=>0.00
  
  protected
  def validate
    errors.add_to_base "Cannot add a line to an invoice that is closed" if self.invoice && self.invoice.closed?
  end
end
