class SRelation < ActiveRecord::Base
  has_many :relations, :dependent => :destroy
end
