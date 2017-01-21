class Sentence < ActiveRecord::Base
  belongs_to :construction
  has_one :morpheme_set, :dependent => :destroy
  has_one :frame_set, :dependent => :destroy
end
