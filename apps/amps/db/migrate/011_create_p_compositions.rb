class CreatePCompositions < ActiveRecord::Migration
  def self.up
    create_table :p_compositions do |table|
      table.column :morpheme_id, :integer
      table.column :primitive_id, :integer
    end
  end

  def self.down
    drop_table :p_compositions
  end
end
