#class Primitive is subclassed to 
#Constant, Evoker, and Unevoker
class CreatePrimitives < ActiveRecord::Migration
  def self.up
    create_table :primitives do |table|
      table.column :form, :string
      table.column :color, :string    
      table.column :form_set, :string  
      table.column :phon_set, :string  
      table.column :alt_set, :string
      table.column :frame_id, :integer
      table.column :rprim_id, :integer
      table.column :dprim_id, :integer
      table.column :type, :string
    end
  end

  def self.down
    drop_table :primitives
  end
end
