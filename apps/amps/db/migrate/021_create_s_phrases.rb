class CreateSPhrases < ActiveRecord::Migration
  def self.up
    create_table :s_phrases do |table|
      table.column :form, :string
      table.column :phrases_count, :integer, :default => 0
      table.column :cls, :string
    end
  end

  def self.down
    drop_table :s_phrases
  end
end
