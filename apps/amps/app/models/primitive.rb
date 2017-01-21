class Primitive < ActiveRecord::Base
  belongs_to :frame
  has_many :e_compositions, :dependent => :destroy
  has_many :s_elements, :through => :e_compositions
  has_many :p_compositions, :dependent => :destroy
  has_many :morphemes, :through => :p_compositions
  has_many :r_compositions, :dependent => :destroy
  has_many :phrases, :through => :r_compositions
  
  has_one :lprim, :foreign_key => :rprim_id, :class_name => self.to_s
  belongs_to :rprim, :class_name => self
  has_one :uprim, :foreign_key => :dprim_id, :class_name => self.to_s
  belongs_to :dprim, :class_name => self
  
  before_destroy :unschematize 
  
  def unschematize
    SElement.transaction do
      s_elements = self.s_elements
      s_elements do |s_element|
        sc = s_element.primitives_count
        s_element.primitives_count =  sc - 1
        s_element.save!
      end
    end
  end
end

