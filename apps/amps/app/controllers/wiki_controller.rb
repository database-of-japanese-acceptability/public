require 'rubygems'
require 'redcloth'

class WikiController < ApplicationController
  existing_pages = Wiki.find(:all).collect(&:identifier)
  before_filter :login_required, :only => [:show] if $conf[:authenticate]
   
  #caches_action *existing_pages
    
  NUM_MSFA = Sentence.count
  NUM_MORPH    = Morpheme.count
  NUM_FRAME    = Frame.count
  NUM_PRIMITIVE  = Primitive.count
  NUM_SMORPH    = SMorpheme.count
  NUM_SFRAME    = SFrame.count
  NUM_SPRIMITIVE  = SElement.count
  NUM_SPHRASE   = SPhrase.count
  NUM_RELATION = Relation.count
  NUM_SRELATION = SRelation.count
  NUM_SMORPHSET = SMorphemeSet.count
  NUM_SFRAMESET = SFrameSet.count
  NUM_CONSTRUCTION = Construction.count
  
  def self.wiki_constants
    ["NUM_MSFA", "NUM_MORPH", "NUM_FRAME", "NUM_PRIMITIVE",
     "NUM_SMORPH", "NUM_SFRAME", "NUM_SPRIMITIVE", "NUM_SPHRASE",
     "NUM_SRELATION", "NUM_RELATION",
     "NUM_SMORPHSET", "NUM_SFRAMESET", "NUM_CONSTRUCTION"]
  end

  def show
    @page ||= Wiki.find(params[:id])
    # [[identifier]]
    body = @page.body.gsub(/\[\[([^\]\|]+)\]\]/) do 
      "<a href='" + url_for(:controller => :wiki, :action => $1) + "'>" + $1 + "</a>"
    end
    # [[identifier|title]]
    body = body.gsub(/\[\[([^\]\|]+)\|([^\]]+)\]\]/) do
      "<a href='" + url_for(:controller => :wiki, :action => $1) + "'>" + $2 + "</a>"
    end
    # #{}
    body = body.gsub(/#\{([^\}]+)\}/) do
      if WikiController.wiki_constants.index($1)
        eval($1).to_s
      else
        $1
      end
    end
    # image links
    body = body.gsub(/!([^!]+?)!/) do
      match = $1
      if /\A#{$conf[:prefix]}/ =~ match
        '!' + match + '!'
      else
        '!' + $conf[:prefix] + '/' + match + '!'
      end
    end
    @page.body = RedCloth.new(body).to_html
    render :action => :show
  end

  def edit
    @page = Wiki.find(params[:id])
  end

  def create
    render :action => :create
  end

  def save
    identifier = params[:page][:identifier]
    delete_cache(identifier)
    title = params[:page][:title]
    body  = params[:page][:body]
    begin
      @page = Wiki.find(:first, :conditions => ["identifier = ?", identifier])
    rescue
      @page = nil
    end
    if @page
      @page.body = body
      @page.identifier = identifier
      @page.title = title
      @page.save!
    else
      @page = Wiki.create!(:identifier => identifier, 
                           :body => body,
                           :title => title)
    end
    redirect_to :action => :show, :id => @page
  end

  def delete
    page = Wiki.find(params[:id])
    delete_cache(page.identifier)
    page.destroy
    redirect_to :action => :index
    #flash[:message] = "削除しました"
  end

  def method_missing(identifier, *args)
    @identifier = identifier
    begin
      @page = Wiki.find(:first, :conditions=>["identifier = ?", @identifier])
    rescue
      @page = nil
    end
    if @page
      show
    else
      create
      delete_cache(@identifier)      
    end
  end

  private

  def delete_cache(identifier)
      expire_action(:controller => "/wiki", :action => identifier)
      if identifier == "index"
        expire_action(:controller => "/", :action => "index")
      end
  end  
end
