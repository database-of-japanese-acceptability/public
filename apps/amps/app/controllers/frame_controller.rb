class FrameController < ApplicationController
  # before_filter :login_required if $conf[:authenticate]
  caches_action :list

  def search
    @params = (params || {})
    @keyword ||=params[:search][:text]
    @regexp = params[:search][:regexp] == "1" ? true : false
    @ffreq = 1
    if @params[:filter] and @params[:filter][:freq]
      @ffreq = @params[:filter][:freq]
    end    
    if @regexp
      begin
        @s_frames  = SFrame.find(:all, :conditions => ["frames_count > ?", @ffreq],
          :order => "frames_count DESC").select do |sf|
          /#{@keyword}/ =~ sf.form
        end
        @specifiers = @s_frames.select{|sf| sf.cls == "Specifier"}
        @nonspecifiers = @s_frames.select{|sf| sf.cls == "Nonspecifier"}
      rescue  RegexpError
        flash[:message] = "ERROR in Regular Expression"
        redirect_to :action => :list
        return
      end
    else
      @s_frames = SFrame.find(:all, :order => "frames_count DESC",
        :conditions =>["(frames_count > ?) AND (form LIKE ?)", @ffreq, "%#{@keyword}%"])
      @specifiers = @s_frames.select{|sf| sf.cls == "Specifier"}
      @nonspecifiers = @s_frames.select{|sf| sf.cls == "Nonspecifier"}
    end
    if @params["order_by"] == "freq"
      @specifiers = @specifiers.sort_by{|s|[-s.frames_count, -s.form.length]}
      @nonspecifiers = @nonspecifiers.sort_by{|s|[-s.frames_count, -s.form.length]}
    elsif @params["order_by"] == "alpha"
      @specifiers = @specifiers.sort_by{|s|[s.form]}
      @nonspecifiers = @nonspecifiers.sort_by{|s|[s.form]}
    elsif @params["order_by"] == "length"
      @specifiers = @specifiers.sort_by{|s|[-s.form.length, -s.frames_count]}
      @nonspecifiers = @nonspecifiers.sort_by{|s|[-s.form.length, -s.frames_count]}
    end    
  end
  
  def list
   @params = (params || {})
   @params["order_by"] = "freq" unless @params["order_by"]
   @ffreq = 1
   if @params[:filter] and @params[:filter][:freq]
     @ffreq = @params[:filter][:freq]
   end     
   @s_frames = SFrame.find(:all, :conditions => ["frames_count > ?", @ffreq],
     :order => "frames_count DESC")
   @specifiers = @s_frames.select{|sf| sf.cls == "Specifier"}
   @nonspecifiers = @s_frames.select{|sf| sf.cls == "Nonspecifier"}
   if @params["order_by"] == "freq"
     @specifiers = @specifiers.sort_by{|s|[-s.frames_count, -s.form.length]}
     @nonspecifiers = @nonspecifiers.sort_by{|s|[-s.frames_count, -s.form.length]}
    elsif @params["order_by"] == "alpha"
      @specifiers = @specifiers.sort_by{|s|[s.form]}
      @nonspecifiers = @nonspecifiers.sort_by{|s|[s.form]}
   elsif @params["order_by"] == "length"
     @specifiers = @specifiers.sort_by{|s|[-s.form.length, -s.frames_count]}
     @nonspecifiers = @nonspecifiers.sort_by{|s|[-s.form.length, -s.frames_count]}
   end
  end

  def show
    @form = params[:form]
    frames   = Frame.find(:all, :conditions => ["form = ?", @form])
    frame_sets = frames.collect{ |f|  f.frame_set }.uniq
    @frame_sets = FrameSet.find(:all, :conditions => ["id IN (?)", frame_sets])
    if params[:id]
      @ids = params[:id].split('-')
    else
      frames = Frame.find(:all, :conditions => ["form = ?", @form])
      @ids = frames.collect {|f| f.frame_set}.uniq
    end
    @frame_sets = FrameSet.find(:all, :conditions => ["id IN (?)", @ids])
  end
  
  def specify
    data(params[:id])
  end
  
  private
  
  def data(id)
    @id = id
    @s_frame = SFrame.find(@id, :include => {:frames => {:frame_set => :sentence}})
    frames = @s_frame.frames
    frame_hash = {}
    s_element_hash = {}
    frames.each do |f|
      if frame_hash[f.form]
        frame_hash[f.form] << f
      else
        frame_hash[f.form] = [f]
      end
      f.primitives.each do |p|
        sps = p.s_elements
        sps.each do |sp|
          next unless sp.respond_to?(:form)
          if s_element_hash[sp.form]
            s_element_hash[sp.form] << p
          else
            s_element_hash[sp.form] = [p]
          end
        end
      end
    end
    @frame_array = frame_hash.sort_by{ |key, value| [value.length, key]}.reverse
    @s_element_array = s_element_hash.sort_by{ |key, value| [value.length, key]}.reverse

    tos = Relation.find(:all, :conditions => ["source_id IN (?)", frames])
    to_hash = {}
    tos.each do |to|
      key = @s_frame.form + ' ' + to.nature + ' ' + Frame.find(to.target.id).s_frame.form
      if to_hash[key]
        to_hash[key] << to
      else
        to_hash[key] = [to]
      end
    end
    if to_hash.empty?
      @to_array = nil
    else
      @to_array = to_hash.sort_by{ |key, value | [value[0].nature, value.length, -(key.length)] }.reverse
    end
    froms = Relation.find(:all, :conditions => ["target_id IN (?)", frames])
    from_hash = {}
    froms.each do |from|
      key = Frame.find(from.source.id).s_frame.form + ' ' + from.nature + ' ' + @s_frame.form
      if from_hash[key]
        from_hash[key] << from
      else
        from_hash[key] = [from]
      end
    end
    if from_hash.empty?
      @from_array = nil
    else
      from_hash.keys
      from_hash.values
      @from_array = from_hash.sort_by{ |key, value | [value[0].nature, value.length, -(key.length)] }.reverse
    end

    multiple = []
    single = []
    @s_element_array.each do |item|
      if item[1].size > 1
        multiple << item
      else
        single << item
      end
    end

    if multiple.length > 1
      num_singles = single.inject(0) do |result, item|
        result += item[1].size or 0
      end    
      legend_array = multiple.collect{|m|m[0].gsub(",", "，")}
      legend_array << "その他" if num_singles and num_singles > 0
      value_array = multiple.collect{|m|m[1].length}
      value_array << num_singles if num_singles and num_singles > 0
      gurl = url_for(:controller => :graph, :action => :bar,
                   :items => legend_array, :values => value_array)
      @graph = open_flash_chart_object(30 + 30 * value_array.length ,250, gurl, false, "#{$conf[:prefix]}/")     
    else
      @graph = ""
    end
  end
end
