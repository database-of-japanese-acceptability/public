class SFrame < ActiveRecord::Base
  has_many :frames
  has_many :f_compositions, :dependent => :destroy
	has_many :s_frame_sets, :through => :f_compositions
	belongs_to :s_frame_set
end
