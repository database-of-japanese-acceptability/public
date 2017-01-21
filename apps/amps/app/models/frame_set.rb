class FrameSet < ActiveRecord::Base
  belongs_to :sentence
	belongs_to :s_frame_set
  has_many :frames, :dependent => :destroy
  before_destroy :unschematize

  def unschematize
    SFrameSet.transaction do
      s_frame_set = self.s_frame_set
      s_frame_set.frame_sets_count =  s_frame_set.frame_sets_count - 1
      s_frame_set.save!
      #todo: delete SFrameSet instance object when its count == 0
    end
  end  
end
