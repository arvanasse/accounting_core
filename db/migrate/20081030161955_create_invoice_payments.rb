class CreateInvoicePayments < ActiveRecord::Migration
  def self.up
    create_table :invoice_payments do |t|
      t.references :invoice
      t.references :receipt
      t.decimal    :amount, :precision=>11, :scale=>2

      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_payments
  end
end
