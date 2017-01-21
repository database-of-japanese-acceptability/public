class CreateSFrames < ActiveRecord::Migration
  def self.up
    create_table :s_frames do |table|
      table.column :form, :string
      table.column :frames_count, :integer, :default => 0
      table.column :cls, :string
    end
  end

  def self.down
    drop_table :s_frames
  end
end
