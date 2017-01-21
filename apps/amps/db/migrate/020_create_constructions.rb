class CreateConstructions < ActiveRecord::Migration
  def self.up
    create_table :constructions do |table|
      table.column :s_frame_set_id, :integer
      table.column :s_morpheme_set_id, :integer   
    end
  end

  def self.down
    drop_table :constructions
  end
end
