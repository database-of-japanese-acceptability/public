class MsfaController < ApplicationController
  before_filter :login_required if $conf[:authenticate]

	# FILE_DIR = "#{RAILS_ROOT}/public/files/"
	FILE_DIR = "#{RAILS_ROOT}/data/files/"
	
	def initialize
	  @file_dir = FILE_DIR
	  @converted = Sentence.find(:all,:order=>"filename").reverse
	  @not_converted = Dir.entries(FILE_DIR).delete_if do |file|
	    bn = File.basename(file)
	    /.*\.xml$/ !~ bn or Sentence.find(:first, :conditions => ["filename = ?", bn])
	  end.sort.reverse
	end
	
	def upload
	end
	
  def save
    file = params['msfa_input']['data']
    if file == ""
      flash[:message] = "ファイル名が指定されていません。"
      redirect_to :action => :upload
      return
    end
    @basename = File.basename(file.original_filename)
  	filelist = @not_converted + @converted.collect {|c| c.filename}
  	filelist.each do |f|
  	  if File.basename(f) == @basename
  	    flash[:message] = "アップロードできません。同じ名前のファイルがあります。"
        redirect_to :action => :upload
        return
  	  elsif /\.xml/ !~ @basename
  	    flash[:message] = "拡張子が .xml 以外のファイルはアップロードできません。"
        redirect_to :action => :upload
  	    return
  	  end
  	end
    data = file.read
    if data.size == 0
	    flash[:message] = "指定されたファイルにデータが存在していません。"
	    initialize
      redirect_to :action => :upload
	    return
    end
    File.open(FILE_DIR + @basename, "wb") do |f| 
      f.write(data)
    end
    flash[:message] = "アップロードが完了しました。"
    redirect_to :action => :upload
  end
  
  def delete
    require 'msfa_utils' #to call check_schemata method
    extend MsfaUtils
    @basename = File.basename(Sentence.find(params[:id]).filename)
    delete_cache_sentence(params[:id])
    delete_cache_lists
    #delete relations
    sentence = Sentence.find(params[:id])
    frames = sentence.frame_set.frames
    frames.each do |f|
      f.relations.each do |r|
        r.destroy
      end
    end
    sentence.destroy
    check_schemata
    initialize
    flash[:message] = "#{@basename}のデータを削除しました。"
    render :partial => 'file_list'
  end

  def delete_file
    basename = File.basename(params[:filename])
    begin
      # File.unlink(File.join(RAILS_ROOT, "public", "files", basename))
      File.unlink(File.join(RAILS_ROOT, "data", "files", basename))
    rescue
      initialize
      flash[:message] = "#{basename}を削除出来ませんでした。"
      render :partial => 'file_list'
      return
    end
    initialize
    flash[:message] = "#{basename}を削除しました。"
    render :partial => 'file_list'
  end
  
  def convert
    require 'msfa'
    require 'db_converter'
    delete_cache_lists
    basename = File.basename(params[:filename])
    db_converter = DBConverter.new(basename)
    s_id = db_converter.convert
    flash[:message] = "#{basename}のデータの変換に成功しました。"
    initialize
    render :partial => 'file_list'
  end
  
  def convert_all
    flash[:message] = ""
    delete_cache_lists
    @not_converted[0,5].each do |basename|
      db_converter = DBConverter.new(basename)
      s_id = db_converter.convert
      flash[:message] << "#{basename}のデータ変換に成功しました。<br />"
    end
    initialize
    render :partial => 'file_list'
  end
  
  private

  def delete_cache_sentence(s_id)
    expire_action(:controller => '/sentence', :action => 'show_html', :id => s_id)
    png = File.join(RAILS_ROOT, "public", "sentence", "generate_img", s_id.to_s + ".png")
    File.unlink(png) if File.exists?(png)
  end
  
  def delete_cache_lists
    models = ["sentence", "morpheme", "frame", "phrase", "relation"]
    models.each do |model|
      expire_action(:controller => "/#{model}", :action => 'list')
    end
    expire_fragment(:controller => :primitive, :action => :list)
  end
end

