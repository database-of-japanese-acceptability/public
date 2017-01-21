class CreateSRelations < ActiveRecord::Migration
  def self.up
    create_table :s_relations do |t|
      t.column :nature, :string
      t.column :relations_count, :integer, :default => 0      
    end
  end

  def self.down
    drop_table :s_relations
  end
end
