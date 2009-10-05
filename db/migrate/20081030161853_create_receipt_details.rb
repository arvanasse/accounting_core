class CreateReceiptDetails < ActiveRecord::Migration
  def self.up
    create_table    :receipt_details do |t|
      t.references  :receipt
      t.references  :payment_instrument
      t.decimal     :amount, :precision=>11, :scale=>2
      t.integer     :reference_number

      t.timestamps
    end
  end

  def self.down
    drop_table :receipt_details
  end
end
