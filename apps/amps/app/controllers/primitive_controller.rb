class PrimitiveController < ApplicationController
  # before_filter :login_required if $conf[:authenticate]

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
        @s_elements_gov_evo = SElement.find(:all,
                                   :conditions => ["primitives_count > ?", @ffreq],
                                   :order => "primitives_count DESC",
                                   :conditions => "cls = 'Evoker'").select do |sp|
                                     /#{@keyword}/ =~ sp.form
                                   end
        @s_elements_const = SElement.find(:all, 
                                   :conditions => ["primitives_count > ?", @ffreq],
                                   :order => "primitives_count DESC",
                                   :conditions => "cls = 'Constant'").select do |sp|
                                     /#{@keyword}/ =~ sp.form
                                   end
        @s_elements_else = SElement.find(:all, 
                                   :conditions => ["primitives_count > ?", @ffreq],
                                   :order => "primitives_count DESC",
                                   :conditions => "cls = 'Nonevoker'").select do |sp|
                                      /#{@keyword}/ =~ sp.form
                                   end
      rescue  RegexpError => e
        flash[:message] = "ERROR in Regular Expression"
        redirect_to :action => :list
        return
      end
    else
      @s_elements_gov_evo = SElement.find(:all, :order => "primitives_count DESC",
        :conditions =>["primitives_count > ? AND (cls = ? AND form LIKE ?)", 
        @ffreq, "Evoker", "%#{@keyword}%"])
      @s_elements_const = SElement.find(:all, :order => "primitives_count DESC",
        :conditions =>["primitives_count > ? AND (cls = ? AND form LIKE ?)", 
        @ffreq, "Constant", "%#{@keyword}%"])
                                  #,:page => {:size => 100, :current => params[:page]})
      @s_elements_else = SElement.find(:all, :order => "primitives_count DESC",
        :conditions =>["primitives_count > ? AND (cls = ? AND form LIKE ?)", 
        @ffreq, "Nonevoker", "%#{@keyword}%"])
    end
  end
  
  def list
    @params = (params || {})    
    @ffreq = 1
    if @params[:filter] and @params[:filter][:freq]
      @ffreq = @params[:filter][:freq]
    end    
    @s_elements_gov_evo = SElement.find(:all, :order => "primitives_count DESC",
      :conditions =>["primitives_count > ? AND cls = ?", @ffreq, "Evoker"])
    @s_elements_const = SElement.find(:all, :order => "primitives_count DESC",
      :conditions =>["primitives_count > ? AND cls = ?", @ffreq, "Constant"])
    @s_elements_else = SElement.find(:all, :order => "primitives_count DESC",
      :conditions =>["primitives_count > ? AND cls = ?", @ffreq, "Nonevoker"])
   gurl = url_for(:controller => :graph, :action => :pie,
                  :items => ["FrameElements (Evokers)",
                             "FrameElements (NonEvokers)",
                             "ConstantElements"],
                  :values => [@s_elements_gov_evo.size,
                             @s_elements_const.size,
                             @s_elements_else.size],
                  :links => ["#evokers", "#nonevokers", "#constants"])
   @graph = open_flash_chart_object(500, 200, gurl, false, "#{$conf[:prefix]}/")     
  end

  def show
    @form = params[:form]
    if params[:frame]
      @ex_key = :frame
      @ex_value = params[:frame]
    elsif params[:morph]
      @ex_key = :morph
      @ex_value = params[:morph]
    else
      @ex_key = @ex_value = nil
    end
    if params[:id]
      @ids = params[:id].split('-')
    else
      primitives = Primitive.find(:all, :conditions => ["form = ?", @form])
      @ids = primitives.collect {|p| p.frame.frame_set}.uniq
    end
    @sentences = Sentence.find(:all, :conditions => ["id IN (?)", @ids])
                               #, :page => {:size => 20, :current => params[:page]})
  end
    
  def specify
    @id = params[:id]
    @s_element = SElement.find(params[:id])
    primitives = @s_element.primitives
    primitive_hash = {}
    primitives.each do |p|
      if primitive_hash[p.form]
        primitive_hash[p.form] << p
      else
        primitive_hash[p.form] = [p]
      end
    end
    # uncomment the following if you'd like to exclude Setting elements
    #primitive_hash = primitive_hash.delete_if do |key, value|
    #  value == ""
    #end
    @primitive_array = primitive_hash.sort_by{ |key, value| [-value.length, key.length, key]}
    @primitive_array.collect! do |key, value|
      array = []
      hash = {}
      value.each do |v|
        if hash[v.form_set]
          hash[v.form_set] << v.frame.frame_set
        else
          hash[v.form_set] = [v.frame.frame_set]
        end
      end
      array = hash.sort_by { |k, v| [-v.length, k.length, k]}
      [key, array]
    end
  end  
end
