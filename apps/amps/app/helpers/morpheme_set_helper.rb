module MorphemeSetHelper
  def morphemes_column(record)
    record.morphemes.collect {|m| m.phon}.join
  end
end
