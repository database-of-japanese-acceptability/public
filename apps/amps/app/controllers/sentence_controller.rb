$KCODE = "UTF-8"

require 'kconv'
require 'tempfile'

class SentenceController < ApplicationController
  # before_filter(:login_required) if $conf[:authenticate]
  caches_page :generate_img
  caches_action :list, :show_html
  
  def index
    redirect_to :action => list
  end

  def search
    @keyword ||=params[:search][:text]
    @regexp = params[:search][:regexp] == "1" ? true : false
    if @regexp
      begin
        morpheme_sets = MorphemeSet.find(:all).select{|ms|/#{@keyword}/ =~ ms.phon}
      rescue  RegexpError => e
        flash[:message] = "ERROR in Regular Expression"
        redirect_to :action => :list
       return
      end
    else
      morpheme_sets = MorphemeSet.find(:all, :conditions =>["phon LIKE ?", "%#{@keyword}%"])
    end
    @sentences = Sentence.find(:all, :order => "filename", :conditions =>["id in (?)", morpheme_sets])
  end
    
  def list
   @sentences = Sentence.find(:all, :order => "filename")
  end

  def show_html
    data
  end

  def show_img
    @id = params[:id]
  end
  
  def generate_img
    data
    dot = @frame_set.dot
    basename = File.basename(@sentence.filename, ".*")
    tmp_dot_no = 0
    tmp_img_no = 0
    if_dot_fname_ok = false
    if_img_fname_ok = false
    while !if_dot_fname_ok
      @tmp_dot = File.join(RAILS_ROOT, "tmp", "dot" + tmp_dot_no.to_s + ".dot")
      if !File.exists?(@tmp_dot)
        if_dot_fname_ok = true
      else
        tmp_dot_no += 1
      end
    end
    while !if_img_fname_ok
      @tmp_img = File.join(RAILS_ROOT, "tmp", "img" + tmp_img_no.to_s + ".png")
      if !File.exists?(@tmp_img)
        if_img_fname_ok = true
      else
        tmp_img_no += 1
      end
    end
    File.open(@tmp_dot, "w") do |f|
      f.puts dot
    end
    if RUBY_PLATFORM.index("win32")
      cmd = "dot -Tpng #{@tmp_dot} -o #{@tmp_img}"      
    else
      cmd = "/usr/local/bin/dot -Tpng #{@tmp_dot} -o #{@tmp_img}"
    end
    io = IO.popen(cmd, "w+")
    io.flush
    io.close
    f = File.open(@tmp_img, "rb")
    img_data = f.read
    f.close
    send_data img_data, :type => 'image/png', :disposition => 'inline', :filename => @id.to_s + ".png"
    File.unlink @tmp_dot
    File.unlink @tmp_img
    GC.start
  end

  def show_dot
    data
    @dot = @frame_set.dot.gsub(/$/, "<br />")
    render(:text => @dot, :layout => false)
  end

  def dl_dot
    data
    @filename = File.basename(@filename, ".*") + ".dot"
    send_data @frame_set.dot, :filename => @filename,
    :type => 'text/plain'
  end  

  def dl_excel
    data
    # send_file File.join(RAILS_ROOT, 'public', 'files', @filename), :filename => @filename
    send_file File.join(RAILS_ROOT, 'data', 'files', @filename), :filename => @filename
  end  

private

  def data
    @id = params[:id]
    @sentence = Sentence.find(@id)
    @filename = @sentence.filename
    @frame_set = @sentence.frame_set
    @frames = @frame_set.frames
    @morpheme_set = @sentence.morpheme_set
    @morphemes = @morpheme_set.morphemes
  end
end
