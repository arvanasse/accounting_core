class CreateLedgerAccounts < ActiveRecord::Migration
  def self.up
    create_table :ledger_accounts do |t|
      t.references :general_ledger
      t.string :uuid
      t.decimal :opening_amount, :precision => 11, :scale => 2
      t.string :opening_balance_type
      t.decimal :reconciled_amount, :precision => 11, :scale => 2
      t.string :reconciled_balance_type
      t.date :reconciled_on
      t.string :name
      t.integer :account_number
      t.string :ledger_type

      t.timestamps
    end
  end

  def self.down
    drop_table :ledger_accounts
  end
end
