class CreateWikis < ActiveRecord::Migration
  def self.up
    create_table :wikis do |t|
      t.column :identifier,     :string
      t.column :title,    :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :body,     :text
    end
  end

  def self.down
    drop_table :wikis
  end
end
