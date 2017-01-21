class CreateSElements < ActiveRecord::Migration
  def self.up
    create_table :s_elements do |table|
      table.column :form, :string
      table.column :primitives_count, :integer, :default => 0
      table.column :cls, :string
    end
  end

  def self.down
    drop_table :s_elements
  end
end
