class ReceiptDetail < ActiveRecord::Base
  belongs_to  :receipt
  belongs_to  :payment_instrument
  
  protected
  def validate
    errors.add_to_base("Cannot add a detail to a receipt that is no longer open") if self.receipt && !self.receipt.open?
  end
end
