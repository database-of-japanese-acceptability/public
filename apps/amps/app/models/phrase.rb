class Phrase < ActiveRecord::Base
  belongs_to :s_phrase
  has_many :r_compositions, :dependent => :destroy
  has_many :primitives, :through => :r_compositions

  before_destroy :unschematize
  
  def unschematize
    SPhrase.transaction do
      s_phrase = self.s_phrase
      s_phrase.phrases_count = s_phrase.phrases_count - 1
      s_phrase.save!
    end
  end
end
