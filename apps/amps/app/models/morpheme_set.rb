class MorphemeSet < ActiveRecord::Base
  belongs_to :sentence
	belongs_to :s_morpheme_set
  has_many :morphemes, :dependent => :destroy
  before_destroy :unschematize
  
  def unschematize
    SMorphemeSet.transaction do
      s_morpheme_set = self.s_morpheme_set
      s_morpheme_set.morpheme_sets_count =  s_morpheme_set.morpheme_sets_count - 1
      s_morpheme_set.save!
      #todo: delete SMorphemeSet instance object when its count == 0
    end
  end  
end
