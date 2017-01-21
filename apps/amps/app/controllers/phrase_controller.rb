class PhraseController < ApplicationController
  # before_filter(:login_required) if $conf[:authenticate]
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
        @s_phrases  = SPhrase.find(:all, :conditions => ["phrases_count > ?", @ffreq],
          :order => "phrases_count DESC").select do |sp|
          /#{@keyword}/ =~ sp.form
        end
      rescue  RegexpError => e
        flash[:message] = "ERROR in Regular Expression"
        redirect_to :action => :list
        return
      end
    else
      @s_phrases = SPhrase.find(:all, :order => "phrases_count DESC",
        :conditions =>["(phrases_count > ?) AND (form LIKE ?)", @ffreq, "%#{@keyword}%"])
    end
    if @params[:order_by] == "freq"
      @s_phrases = @s_phrases.sort_by{|s|[-s.phrases_count, -s.form.length]}
    elsif @params[:order_by] == "alpha"
      @s_phrases = @s_phrases.sort_by{|s|[s.form]}
    elsif @params[:order_by] == "length"
      @s_phrases = @s_phrases.sort_by{|s|[-s.form.length, -s.phrases_count]}
    end       
  end
 
  def list
    @params = (params || {})
    @params[:order_by] = "freq" unless @params[:order_by]
    @ffreq = 1
    if @params[:filter] and @params[:filter][:freq]
      @ffreq = @params[:filter][:freq]
    end
    @s_phrases = SPhrase.find(:all, :conditions => ["phrases_count > ?", @ffreq],
      :order => "phrases_count DESC")
    if @params[:order_by] == "freq"
      @s_phrases = @s_phrases.sort_by{|s|[-s.phrases_count, -s.form.length]}
    elsif @params[:order_by] == "alpha"
      @s_phrases = @s_phrases.sort_by{|s|[s.form]}
    elsif @params[:order_by] == "length"
      @s_phrases = @s_phrases.sort_by{|s|[-s.form.length, -s.phrases_count]}
    end   
  end

  def show
    @ids = params[:id].split('-')
    @sentences = Sentence.find(:all, :conditions => ["id IN (?)", @ids]) 
    @form = params[:form]
  end
  
  def specify
    @id = params[:id]
    @s_phrase = SPhrase.find(params[:id])
    @phrases = @s_phrase.phrases
    phrase_hash = {}
    @phrases.each do |p|
      sentence = p.primitives.first.frame.frame_set.sentence
      pform = p.primitives.collect{|p|p.form_set}.join('+')
      if phrase_hash[pform]
        phrase_hash[pform] << sentence
      else
        phrase_hash[pform] = [sentence]
      end
    end
    @phrase_array = phrase_hash.sort_by{ |key, value| [-value.length, key.length, key]}
  end
end
