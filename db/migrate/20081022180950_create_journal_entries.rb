class CreateJournalEntries < ActiveRecord::Migration
  def self.up
    create_table :journal_entries do |t|
      t.references :journal
      t.string     :description
      t.string     :state
      t.references :void_for

      t.timestamps
    end
  end

  def self.down
    drop_table :journal_entries
  end
end
