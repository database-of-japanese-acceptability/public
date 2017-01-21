class CreateFrameSets < ActiveRecord::Migration
  def self.up
    create_table :frame_sets do |table|
      table.column :form, :text
      table.column :sentence_id, :integer  
      table.column :s_frame_set_id, :integer  
      table.column :dot, :text
    end
  end

  def self.down
    drop_table :frame_sets
  end
end
