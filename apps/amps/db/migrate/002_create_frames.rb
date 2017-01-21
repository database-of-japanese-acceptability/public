class CreateFrames < ActiveRecord::Migration
  def self.up
    create_table :frames do |table|
      table.column :fid,  :string
      table.column :form, :string
      table.column :relation, :string
      table.column :frame_set_id, :integer
      table.column :s_frame_id, :integer      
      table.column :type, :string
    end
  end

  def self.down
    drop_table :frames
  end
end
