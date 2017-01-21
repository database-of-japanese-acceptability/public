class CreateMorphemeSets < ActiveRecord::Migration
  def self.up
    create_table :morpheme_sets do |table|
      table.column :form, :text
      table.column :phon, :text
      table.column :s_morpheme_set_id, :integer  
      table.column :sentence_id, :integer
    end
  end

  def self.down
    drop_table :morpheme_sets
  end
end
