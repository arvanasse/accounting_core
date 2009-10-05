class CreateSubledgerEntries < ActiveRecord::Migration
  def self.up
    create_table :subledger_entries do |t|
      t.references :subledger_account
      t.references :journal_entry
      t.string :balance_type
      t.decimal :amount, :precision => 11, :scale => 2
      t.date :recorded_on
      t.date :posted_on
      t.string :state
      t.references :created_by
      t.references :update_by

      t.timestamps
    end
  end

  def self.down
    drop_table :subledger_entries
  end
end
