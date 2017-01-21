class MComposition < ActiveRecord::Base
  belongs_to :s_morpheme_set
  belongs_to :s_morpheme
end
