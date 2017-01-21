module PrimitiveHelper
  def sentences(s_element)
    primitives = s_element.primitives
    sentences = primitives.collect{ |p|  p.frame.frame_set.sentence }.uniq
  end
end
