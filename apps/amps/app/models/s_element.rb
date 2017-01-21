class SElement < ActiveRecord::Base
  has_many :e_compositions, :dependent => :destroy
  has_many :primitives, :through => :e_compositions  
end
