class CreateRCompositions < ActiveRecord::Migration
  def self.up
    create_table :r_compositions do |table|
      table.column :primitive_id, :integer
      table.column :phrase_id, :integer
    end
  end

  def self.down
    drop_table :r_compositions
  end
end
