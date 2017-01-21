class CreateECompositions < ActiveRecord::Migration
  def self.up
    create_table :e_compositions do |table|
      table.column :s_element_id, :integer
      table.column :primitive_id, :integer
    end
  end

  def self.down
    drop_table :e_compositions
  end
end
