class CreateReceipts < ActiveRecord::Migration
  def self.up
    create_table :receipts do |t|
      t.references  :subledger_account
      t.references  :journal_entry
      t.date        :posted_on
      t.string      :status
      t.timestamps
    end
  end

  def self.down
    drop_table :receipts
  end
end
