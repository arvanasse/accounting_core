class CreateJournalDetails < ActiveRecord::Migration
  def self.up
    create_table :journal_details do |t|
      t.references  :journal_entry
      t.references  :account, :polymorphic=>true
      t.decimal     :amount, :precision=>11, :scale=>2
      t.string      :balance_type

      t.timestamps
    end
  end

  def self.down
    drop_table :journal_details
  end
end
