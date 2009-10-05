class CreateJournals < ActiveRecord::Migration
  def self.up
    create_table :journals do |t|
      t.references :general_ledger
      t.string :name
      t.string :journal_type
      t.string :uuid

      t.timestamps
    end
  end

  def self.down
    drop_table :journals
  end
end
