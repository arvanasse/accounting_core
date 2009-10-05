class CreateGeneralLedgers < ActiveRecord::Migration
  def self.up
    create_table :general_ledgers do |t|
      t.string :name
      t.string :uuid

      t.timestamps
    end
  end

  def self.down
    drop_table :general_ledgers
  end
end
