class CreateSubledgerAccounts < ActiveRecord::Migration
  def self.up
    create_table :subledger_accounts do |t|
      t.references :ledger_account
      t.string :uuid
      t.string :opening_balance_type
      t.decimal :opening_amount, :precision => 11, :scale => 2
      t.string :reconciled_balance_type
      t.decimal :reconciled_amount, :precision => 11, :scale => 2
      t.date :reconciled_on

      t.timestamps
    end
  end

  def self.down
    drop_table :subledger_accounts
  end
end
