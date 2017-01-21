class CreateFCompositions < ActiveRecord::Migration
  def self.up
    create_table :f_compositions do |table|
      table.column :s_frame_set_id, :integer
      table.column :s_frame_id, :integer
    end
  end

  def self.down
    drop_table :f_compositions
  end
end
