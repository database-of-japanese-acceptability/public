class CreateMCompositions < ActiveRecord::Migration
  def self.up
    create_table :m_compositions do |table|
      table.column :s_morpheme_set_id, :integer
      table.column :s_morpheme_id, :integer
    end
  end

  def self.down
    drop_table :m_compositions
  end
end
