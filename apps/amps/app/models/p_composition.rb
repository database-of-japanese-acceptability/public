class PComposition < ActiveRecord::Base
  belongs_to :morpheme
  belongs_to :primitive
end
