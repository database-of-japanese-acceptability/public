module MsfaUtils
  def check_schemata
    #add S(chematic) items when a necessity arises
    schematic = {SElement => "primitives", 
                 SPhrase => "phrases",
                 SFrame => "frames", 
                 SMorpheme => "morphemes",
                 SRelation => "relations",
                 SMorphemeSet => "morpheme_sets",
                 SFrameSet => "frame_sets",
                 Construction => "sentences"
    }
    schematic.each do |schemata, instances|
      schemata.transaction do
        schemata.find(:all).each do |schema|
          #as to each schema, destroy it if it does not have
          #(not-schematic) instantiations, i.e. instances of
          #Primitive, Frame, Morpheme
          schema.destroy if schema and schema.send(instances).empty?
        end
      end
    end
  end
end
