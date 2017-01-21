class CreateMorphemes < ActiveRecord::Migration
  def self.up
    create_table :morphemes do |table|
      table.column :form, :string
      table.column :phon, :string
      table.column :alt, :string
      table.column :morpheme_set_id, :integer
      table.column :s_morpheme_id, :integer
      table.column :type, :string
    end
  end

  def self.down
    drop_table :morphemes
  end
end
