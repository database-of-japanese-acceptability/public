class Relation < ActiveRecord::Base
  belongs_to :source, :class_name => "Frame"
  belongs_to :target, :class_name => "Frame"
  belongs_to :s_relation
  before_destroy :unschematize
  
  def unschematize
    SRelation.transaction do
      sr = self.s_relation
      sc = sr.relations_count
      sr.relations_count =  sc - 1
      sr.save!
    end
  end
end
