class SMorphemeSet < ActiveRecord::Base
	has_many :constructions
  has_many :morpheme_sets
  has_many :m_compositions, :dependent => :destroy
	has_many :s_morphemes, :through => :m_compositions
end
