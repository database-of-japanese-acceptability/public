$KCODE = "utf-8"

require 'msfa'
require 'kconv'
# FILE_DIR = File.join(File.dirname(__FILE__), '..', 'public', 'files')
FILE_DIR = File.join(File.dirname(__FILE__), '..', 'data', 'files')

class DBConverter
 
  FFR = %w(presupposes targets elaborates characterizes presumes precedes 
	         supports prepares realizes alternates_with part_of causes 
					 instantiates integrates motivates parallels)  
  attr_reader :msfa
  
  def initialize(msfa_input)
    #@msfa_input is the base name of the file under processing,
    #which is in the format of Excel's XML Spreadsheet. 
    @msfa_input = msfa_input
    xml = File.read(File.join(FILE_DIR, @msfa_input))
    @msfa = Msfa.new(xml)
  end

  def convert
    frames = []
    sentence = nil
    s_frame_set = nil
    s_morpheme_set = nil

    Sentence.transaction do
      sentence = Sentence.create!(:filename => @msfa_input)
    end

    FrameSet.transaction do
      frame_set = FrameSet.new(:form => "")
      frame_set.sentence = sentence
      frame_set.dot = @msfa.make_dot
      #@msfa.ids are frame ids such as F0, F1, F2, etc.
      @msfa.ids.each_with_index do |fid, index|
        Frame.transaction do
          frame = Frame.new(:fid => fid, :form => @msfa.frames[index], 
                            :relation => @msfa.relations[index])
          frame.frame_set = frame_set
          frame.save!
          schematize_frame(frame)          
          frames << frame
        end
      end
      frame_set.form = '/' + @msfa.frames.join("/") + '/'

      frame_set.save!

      #analyze frame-to-frame ralations in the frame_set
      frame_set.frames.each do |frame|
        next unless frame.relation
        #puts "------"
        #puts "set:" + frame.relation
        frame.relation.strip.split(';').each do |rel|
          rel = rel.strip
          #puts "rel:" + rel if rel != ""
          items = rel.split(',')
          nature, first_fid = items[0].split(' ', 2)
          fids = [first_fid] + items[1..-1]
          fids.each do |fid|
            new_tgt = frame_set.frames.find(:first, :conditions => ["fid = ?", fid])
            next unless new_tgt
            frame.targets << new_tgt
            new_rel = frame.tos.find(:all, :conditions => ["relations.target_id = ?", new_tgt])[-1]
            #puts "each:" + nature + ":" + fid.to_s
            new_rel.nature = nature
            frame.save!
            new_rel.save!
          end
        end
      end
			
			#create schematic_frame_set
			s_frames = frame_set.frames.collect(&:s_frame)
			sfs_id = s_frames.collect(&:id).join('-')
      s_frame_sets = SFrameSet.find(:all)
			s_frame_set = nil
			if !s_frame_sets or s_frame_sets.empty?
	      s_frame_sets.each do |sfs|
  		    if sfs.s_frames.collect(&:s_frame).collect(&:id).join('-') ==  sfs_id
	  		    s_frame_set = sfs
		  	    break
			  	end
			  end
			end
			unless s_frame_set
			  s_frame_set = SFrameSet.create!
	    	s_frames.each do |sf|
			    s_frame_set.s_frames << sf
				end
			end
			s_frame_set.frame_sets << frame_set
			s_frame_set.frame_sets_count = s_frame_set.frame_sets_count += 1
			s_frame_set.save!
    end
    #morphemes in braces must be removed when creating
    #the form of a morpheme set
    flg_in_braces = false
    
    MorphemeSet.transaction do
      morpheme_set = MorphemeSet.new(:form => "")
      morpheme_set.sentence = sentence
      last_row = []
      prev_prims = Array.new(frames.size)
      @msfa.morphemes.each do |row|
        Morpheme.transaction do
          morph = Morpheme.new(:form => "")
          morph.morpheme_set = morpheme_set
          lprim = nil
          row.each_with_index do |cell, index|
            case index
            #obtain morpheme data (form/phon)
            when 0
              #form comprises everything including braces
              morph.form  = cell
              morph.alt = strip_symbols3(cell)
              #the below is code for stripping braces and the like
              #needs to be more accurately handle nested structure!
              cell = strip_parens(cell)   
              if flg_in_braces
                if cell.match(/^.*\](.*)$/)
                  morph.phon = $1
                  flg_in_braces = false
                else
                  morph.phon = ""
                end
              else
                if cell.match(/^([^\[]*)\[.*$/)
                  morph.phon = $1
                  flg_in_braces = true
                else
                  morph.phon = cell
                end
              end
              schematize_morpheme(morph)
              last_row[index] = morph
            #obtain primitive(=frame-element) data
            else
              if cell and cell != ""
                Primitive.transaction do
                  prim = last_row[index]
                  if prim and prim.form == make_form(cell)
                    prim.morphemes << morph
                    prim.save!
                  else
                    prim = create_primitive(cell)
                    prim.uprim = prev_prims[index]
                    prim.lprim = lprim                    
                    prim.morphemes << morph
                    prim.frame = frames[index - 1]
                    prim.save!
                    prev_prims[index] = prim
                    lprim = prim
                    #if index equals 1, the column is for setting, which 
                    #should not be schematize
                    #schematize_primitive(prim) unless index == 1
                  end
                  #originally, a primitive was not thought to contain morph_set;
                  #for processing efficiency, though, it seems inevitable
                  last_row[index] = prim
                end
              end
            end
            morph.save!
          end
        end
      end
      morpheme_set.form = '/' + @msfa.morphemes.collect{|m|m[0]}.join("/") + '/'
      morpheme_set.phon = strip_symbols2(morpheme_set.morphemes.collect { |m| m.form }.join(" "))
      #if morpheme_set contains unmatched braces, report error
      morpheme_set.phon = "Error in MSFA" if morpheme_set.phon == ""
      morpheme_set.save!
			
			#create schematic_morpheme_set
			s_morphemes = morpheme_set.morphemes.collect(&:s_morpheme)
			sms_id = s_morphemes.collect(&:id).join('-')
      s_morpheme_sets = SMorphemeSet.find(:all)
			s_morpheme_set = nil
			if !s_morpheme_sets or s_morpheme_sets.empty?
	      s_morpheme_sets.each do |sms|
  		    if sms.s_morphemes.collect(&:s_morpheme).collect(&:id).join('-') ==  sms_id
	  		    s_morpheme_set = sms
		  	    break
			  	end
			  end
			end
			unless s_morpheme_set
			  s_morpheme_set = SMorphemeSet.create!
	    	s_morphemes.each do |sm|
			    s_morpheme_set.s_morphemes << sm
				end
			end
			s_morpheme_set.morpheme_sets << morpheme_set
			s_morpheme_set.morpheme_sets_count = s_morpheme_set.morpheme_sets_count += 1
			s_morpheme_set.save!
    end
    #setting construction-sentence relation
    construction = Construction.find(:first, 
      :conditions => ["s_frame_set_id = ? AND s_morpheme_set_id = ?", s_frame_set, s_morpheme_set])
    unless construction
      construction = Construction.new(:s_frame_set => s_frame_set, :s_morpheme_set => s_morpheme_set)
    end
    construction.sentences << sentence
    construction.save!
    
    relations = []
    frames.each do |f|
      relations += f.tos
      relations += f.froms
    end
    relations.uniq.each do |r|
		  key = r.nature.strip
			valid = true
			parts = key.split(/_(AND|OR)_/)
			parts.each do |p|
			  next if /(AND|OR)/ =~ p
			  break unless valid
         p = p.sub(/\?(.*)/){$1}
         p = p.sub(/[^\-]+ly_(.*)/){$1}
				valid = false unless FFR.index(p)
			end
			if valid
			  sr = SRelation.find(:first, :conditions => ["nature = ?", key])
         sr = SRelation.create!(:nature => key) unless sr
			else
			  sr = SRelation.find(:first, :conditions => ["nature = ?", "NA"])
         sr = SRelation.create!(:nature => "NA") unless sr
			end
      sr.relations << r
      sr.relations_count = sr.relations_count + 1
      sr.save!
    end
		
    # setting phon_set in primitives
    # and also schematize them
    primitives = []
    frames.each do |fr|
      primitives += fr.primitives
    end
    Primitive.transaction do
      primitives.each do |prim|
        prim.form_set = '/' + prim.morphemes.collect{ |m| m.form}.join + '/'
        phon_set = prim.morphemes.collect{ |m| m.phon }.join
        alt_set = prim.morphemes.collect{ |m| m.alt }.join
        #prim.phon_set = phon_set == "" ? "NULL" : phon_set
        prim.phon_set = phon_set
        prim.alt_set = alt_set
        prim.save!
        # schematize unless the prim is one in "Setting"
        schematize_primitive(prim) unless /\AX/ =~ prim.form
      end
    end

    return sentence.id
  end

  private

  def make_form(cell)
    if /\A(.*)(#[A-Za-z0-9]{6})\z/m =~ cell
      form = $1
    else
      form = cell
    end
    form
  end
  
  def create_primitive(cell)
    form = color = ""
    cls = nil
    # a cell contains text plus color data
    if /\A(.*)(#[A-Za-z0-9]{6})\z/m =~ cell
      form = $1
      color = $2
    else
      form = cell
      color = ""
    end
    Primitive.create(:form => form, :color => color)
  end

  def schematize_frame(instance)
	  if /の指定(\[|\z)/ =~ instance.form
      cls = "Specifier"
    else
      cls = "Nonspecifier"
    end
    schematic_form = process_paren(instance.form)
    #schematic_form = schematic_form == "" ? "NULL" : schematic_form 
    SFrame.transaction do
      schema = SFrame.find(:first, 
        :conditions => {:form => schematic_form, :cls => cls}
      )
      schema ||= SFrame.new(:form => schematic_form,
                            :cls => cls)
      schema.frames << instance
      schema.frames_count = schema.frames_count + 1
      schema.save!
    end
  end

  def schematize_morpheme(instance)
    schematic_form = strip_symbols3(instance.form)
    #schematic_form = schematic_form == "" ? "NULL" : schematic_form 
    SMorpheme.transaction do
      schema = SMorpheme.find(:first, 
        :conditions => {:form => schematic_form, :cls => instance.class.to_s}
      )
      schema ||= SMorpheme.new(:form => schematic_form,
                               :cls => instance.class.to_s)
      schema.morphemes << instance
      schema.morphemes_count = schema.morphemes_count + 1
      schema.save!
    end
  end
 
  def schematize_primitive(instance)
    form = process_paren(instance.form)
    form = process_paren2(form)
    if /\A#/ !~ form
      schematic_forms = parse_primitive(form)
     else
      schematic_forms = [form]
    end    
    
    SPhrase.transaction do
      prim = instance
      sequences = []
      unless /\A#/ =~ instance.form
        sequences << [instance]
      end
      derived = []
      if  /(.*?)\..*(EXT|SUP)/ =~ prim.form
        target = $1      
        derived << prim
        if /^\A#/ !~ prim.form 
          target_esc = Regexp.escape(target)
          target_rgx = /\A\s*#{target_esc}/
          while prim = prim.uprim
            derived << prim
            prim_set = derived.reverse        
            sequences << prim_set
            if target_rgx =~ prim.form
              break unless /[\.=+](EXT|SUP)/ =~ prim.form
            end
          end
        else
          while prim = prim.uprim
            derived << prim
            if /\A#/ !~ prim.form
              break
            end
          end        
          sequences = [derived.reverse]
        end
      end

      Phrase.transaction do
        sequences.each do |seq|
          if /\A#/ !~ seq[-1].form
            form = seq.collect{ |s| s.phon_set }.join
            alt  = seq.collect{ |s| s.alt_set }.join
            sarray = [form, alt]
          else
            carray = []
            seq.each do |s|              
              if /\A#(.*?)(\.|\=|\s*$)/ =~ s.form
                carray << cons_parse($1)
              else
                carray << [s.alt_set]
              end
            end
            sarray = combine(carray)
          end
          
          sarray.uniq.each do |f|          
            next if f == ""
            phrase = Phrase.create!(:form => f)
            seq.each do |s|
              phrase.primitives << s
            end
            phrase.save!
            schema = SPhrase.find(:first, 
                                   :conditions => {:form => f}
            )
            schema ||= SPhrase.create!(:form => f)
            schema.phrases << phrase
            schema.phrases_count = schema.phrases_count + 1
            schema.save!
          end
        end
      end
    end
    
    SElement.transaction do
      schematic_forms.each do |schematic_form|
  	    if /\A#/ =~ schematic_form
					cls = "Constant"
				elsif  /\bMOD\b/ =~ schematic_form
          cls = "Nonevoker"
        elsif  /\bSUP\b/ =~ schematic_form
					cls = "Nonevoker"
				elsif  /\bEXT\b/ =~ schematic_form
					cls = "Nonevoker"
				elsif /\bARGS?\b/ =~ schematic_form
					cls = "Nonevoker"
				elsif /\bEVO\b/ =~ schematic_form
					cls = "Evoker"
					if  /\bPRED\b/ =~ schematic_form
						;
					end
				elsif  /\bGOV\b/ =~ schematic_form
					cls = "Evoker"
				else
				  cls = "Nonevoker"
				end
        schema = SElement.find(:first, 
          :conditions => {:form => schematic_form, :cls => cls}
        )
        schema ||= SElement.create!(:form => schematic_form, :cls => cls)
        schema.primitives << instance
        schema.primitives_count = schema.primitives_count + 1
        schema.save!
      end
    end
  end
  
  def parse_primitive(form)
    sfs  = form.split(/[\;\:]/)
    schematic_forms = []
    sfs.each do |sf|
      temp = sf.split(",")
      if temp.size > 1
        spec = /(\..+)\z/.match(temp[-1]).to_a[1]
        spec = spec ? spec : ""
        temp[0 ... -1].each do |t| 
          t = t ? t : ""
          schematic_forms << (t  + spec).strip
        end
      end
      schematic_forms << (temp[-1]).strip
    end
    schematic_forms
  end
    
  def strip_parens(str)
     str = str.gsub(/\[[^\[\]]+?\]/,"")
     str = strip_symbols(str)
     return str
  end
  
  def strip_symbols(str)
    #convert string like [xxx->yyy] into yyy
    str = str.gsub(/\[.+?->(.+?)\]/){ $1 }
    #remove characters ~ and *
    str = str.gsub(/(~ *|\*)/, "")
    str = process_paren(str)
    return str
  end
  
  def strip_symbols2(str)
    str = strip_symbols(str)
    #apply the following only when the target language is English
    str = str.gsub(/ +/, "") unless /\A[a-zA-Z0-9!-~ ]+\z/ =~ str
    return str
  end

  def strip_symbols3(str)
    #remove characters ~, [, and ]
    str = str.gsub(/\[=[^\]]+\]/, "")
    str = str.gsub(/(~ *|\*|\[|\])/, "")
    return str
  end

  # remove string between [ and ]
  def process_paren(str)
    temp = str
    while str.index('[') and str.index(']')
      opening = []
      temp = ""
      str.split(//).each do |c|
        case c
        when '['
          opening.push(c)
        when ']'
          opening.pop
        else
          temp << c if opening.empty?
        end
      end
      str = temp
    end
    str = temp || ""
    return str
  end
  
  def process_paren2(str)
    str = str.gsub(/<\d+,\s*\d+>/,"")
    str = str.gsub(/=>.+?(\.|\z)/){$1}
  end
  
    def cons_parse(str)
    if /(.*)\{(.+)\}(.*)/ =~ str
      before = $1      
      seq = $2
      after = $3
      items = seq.split(/\s*,\s*/).collect {|i| before + i + after}
    elsif /,/ =~ str
      items = str.split(/\s*,\s*/)
    else
      items = [str]
    end
    return items
  end
  
  def combine(ary)
    result = [""]
    ary.each do |a|
      if a.length > 0
        new_result = []
        a.length.times do |i|
          result.each do |r| 
            new_result << r + a[i]
          end
        end
        result = new_result
      end
      result = new_result
    end
    return result
  end


end

