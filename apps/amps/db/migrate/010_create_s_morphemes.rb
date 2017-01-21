class CreateSMorphemes < ActiveRecord::Migration
  def self.up
    create_table :s_morphemes do |table|
      table.column :form, :string
      table.column :morphemes_count, :integer, :default => 0
      table.column :cls, :string
    end
  end

  def self.down
    drop_table :s_morphemes
  end
end
