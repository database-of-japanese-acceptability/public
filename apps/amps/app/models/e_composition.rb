class EComposition < ActiveRecord::Base
  belongs_to :s_element
  belongs_to :primitive
end
