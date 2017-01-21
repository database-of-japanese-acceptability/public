class Construction < ActiveRecord::Base
  has_many :sentences
  belongs_to :s_frame_set
	belongs_to :s_morpheme_set
end

