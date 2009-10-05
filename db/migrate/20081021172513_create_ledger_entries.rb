class CreateLedgerEntries < ActiveRecord::Migration
  def self.up
    create_table :ledger_entries do |t|
      t.references :ledger_account
      t.references :journal_entry
      t.decimal :amount, :precision => 11, :scale => 2
      t.string :balance_type
      t.date :recorded_on
      t.date :posted_on
      t.string :state
      t.references :created_by
      t.references :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :ledger_entries
  end
end
