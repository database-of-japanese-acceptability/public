class Morpheme < ActiveRecord::Base
  belongs_to :morpheme_set
  belongs_to :s_morpheme
  has_many :p_compositions, :dependent => :destroy
  has_many :primitives, :through => :p_compositions
  
  before_destroy :unschematize
  
  def unschematize
    SMorpheme.transaction do
      s_morpheme = self.s_morpheme
      s_morpheme.morphemes_count =  s_morpheme.morphemes_count - 1
      s_morpheme.save!
      #todo: delete SMorpheme instance object when its count == 0
    end
  end
end
