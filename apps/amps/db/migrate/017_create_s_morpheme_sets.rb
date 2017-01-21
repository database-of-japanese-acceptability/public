class CreateSMorphemeSets < ActiveRecord::Migration
  def self.up
    create_table :s_morpheme_sets do |t|
      t.column :morpheme_sets_count, :integer, :default => 0      
    end
  end

  def self.down
    drop_table :s_morpheme_sets
  end
end
