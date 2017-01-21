class CreatePhrases < ActiveRecord::Migration
  def self.up
    create_table :phrases do |table|
      table.column :form, :string
      table.column :s_phrase_id, :integer
      table.column :type, :string
    end
  end

  def self.down
    drop_table :phrases
  end
end
