class CreateInvoiceLines < ActiveRecord::Migration
  def self.up
    create_table :invoice_lines do |t|
      t.references  :invoice
      t.string      :name
      t.date        :posted_on
      t.references  :charge, :polymorphic=>true
      t.decimal     :amount, :precision=>11, :scale=>2

      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_lines
  end
end
