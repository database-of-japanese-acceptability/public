class Frame < ActiveRecord::Base
  belongs_to :frame_set
  belongs_to :s_frame
  has_many   :primitives, :dependent => :destroy
  #self-referential has-many-through assocition
  has_many :tos,  :foreign_key => 'source_id',
                  :class_name => 'Relation'
  has_many :targets, :through => :tos
  has_many :froms, :foreign_key => 'target_id',
                   :class_name => 'Relation'
  has_many :sources, :through => :froms

  before_destroy :unschematize
  
  def unschematize
    SFrame.transaction do
      s_frame = self.s_frame
      s_frame.frames_count = s_frame.frames_count - 1
      s_frame.save!
    end
  end
  
  def relations
    tos + froms
  end
end
