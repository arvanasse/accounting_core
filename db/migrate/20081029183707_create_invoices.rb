class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.references :subledger_account
      t.references :journal_entry
      t.string     :status
      t.date       :closed_on
      t.string     :name

      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end
