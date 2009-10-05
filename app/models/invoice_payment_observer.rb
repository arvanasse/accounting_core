class InvoicePaymentObserver < ActiveRecord::Observer
  def after_create(payment)
    payment.invoice.mark_paid! if payment.invoice.closed? && payment.invoice.balance_due <= 0
  end
end
