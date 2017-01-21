module SentenceHelper
  
  def link_to_sprim(prim)
    sform = prim.form.sub(/\A([^A-Z]+?)(\..+)\z/){$1 + "<br />" + $2}
    link_to(sform, :controller => :primitive, :action => :show,
                       :form => prim.form)
  end
  
  def link_to_morpheme(morpheme)
    link_to(morpheme.form, :controller => :morpheme, :action => :show,
                        :form => morpheme.form)
  end
  
  def link_to_frame(frame)
    link_to(frame.form, :controller => :frame, :action => :show,
                        :id => frame.frame_set.id,
                        :form => 'Frame ' + frame.form)
  end
end
