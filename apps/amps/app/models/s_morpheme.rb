class SMorpheme < ActiveRecord::Base
  has_many :morphemes
  has_many :m_compositions, :dependent => :destroy
	has_many :s_morpheme_sets, :through => :m_compositions
	belongs_to :s_morpheme_set
end
