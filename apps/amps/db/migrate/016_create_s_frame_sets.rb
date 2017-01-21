class CreateSFrameSets < ActiveRecord::Migration
  def self.up
    create_table :s_frame_sets do |t|
      t.column :frame_sets_count, :integer, :default => 0      
    end
  end

  def self.down
    drop_table :s_frame_sets
  end
end
