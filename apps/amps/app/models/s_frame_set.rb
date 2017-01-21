class SFrameSet < ActiveRecord::Base
	has_many :constructions
  has_many :frame_sets
  has_many :f_compositions, :dependent => :destroy
	has_many :s_frames, :through => :f_compositions
end

