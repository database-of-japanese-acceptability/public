class CreateSentences < ActiveRecord::Migration
  def self.up
    create_table :sentences do |table|
      table.column :construction_id, :integer
      table.column :filename, :string
      table.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :sentences
  end
end
