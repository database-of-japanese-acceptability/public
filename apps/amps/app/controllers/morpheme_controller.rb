class MorphemeController < ApplicationController
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
        @s_morphemes  = SMorpheme.find(:all, :conditions => ["morphemes_count > ?", @ffreq],
          :order => "morphemes_count DESC").select do |sm|
             /#{@keyword}/ =~ sm.form
        end
      rescue  RegexpError => e
        flash[:message] = "ERROR in Regular Expression"
        redirect_to :action => :list
        return
      end
    else
      @s_morphemes = SMorpheme.find(:all, :order => "morphemes_count DESC",
        :conditions =>["(morphemes_count > ?) AND (form LIKE ?)", @ffreq, "%#{@keyword}%"])
    end
    if @params[:order_by] == "freq"
      @s_morphemes = @s_morphemes.sort_by{|s|[-s.morphemes_count, -s.form.length]}
    elsif @params[:order_by] == "alpha"
      @s_morphemes = @s_morphemes.sort_by{|s|[s.form]}
    elsif @params[:order_by] == "length"
      @s_morphemes = @s_morphemes.sort_by{|s|[-s.form.length, -s.morphemes_count]}
    end       
  end
 
  def list
   @params = (params || {})
   @params[:order_by] = "freq" unless @params[:order_by] 
   @ffreq = 1
   if @params[:filter] and @params[:filter][:freq]
     @ffreq = @params[:filter][:freq]
   end   
   @s_morphemes = SMorpheme.find(:all, :conditions => ["morphemes_count > ?", @ffreq],
    :order => "morphemes_count DESC")
    if @params[:order_by] == "freq"
      @s_morphemes = @s_morphemes.sort_by{|s|[-s.morphemes_count, -s.form.length]}
    elsif @params[:order_by] == "alpha"
      @s_morphemes = @s_morphemes.sort_by{|s|[s.form]}
    elsif @params[:order_by] == "length"
      @s_morphemes = @s_morphemes.sort_by{|s|[-s.form.length, -s.morphemes_count]}
    end   
  end


  def show
    @form = params[:form]
    morphemes   = Morpheme.find(:all, :conditions => ["form = ?", @form])
    morpheme_sets = morphemes.collect{ |m|  m.morpheme_set }.uniq
    @morpheme_sets = MorphemeSet.find(:all, :conditions => ["id IN (?)", morpheme_sets])
  end
  
  def specify
    @id = params[:id]
    @s_morpheme = SMorpheme.find(params[:id], :include => {:morphemes => {:morpheme_set => :sentence}})
    morphemes = @s_morpheme.morphemes
    morpheme_hash = {}
    morphemes.each do |m|
      if morpheme_hash[m.form]
        morpheme_hash[m.form] << m
      else
        morpheme_hash[m.form] = [m]
      end
    end
    @morpheme_array = morpheme_hash.sort_by{ |key, value| [value.length, key]}.reverse
  end
end
