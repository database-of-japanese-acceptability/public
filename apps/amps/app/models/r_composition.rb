class RComposition < ActiveRecord::Base
  belongs_to :primitive
  belongs_to :phrase
end
