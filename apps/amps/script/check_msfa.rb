require 'kconv'
require 'rexml/document'
include REXML

class Msfa
  # @xml:       the row XML data
  # @doc:       parsed structure of XML
  # @ids:       frame ids, e.g. F0, F1, F2, etc.
  # @relations: frame-to-frame relations, 
  #             e.g. "possibly_targets -> F2"
  # @names:     names of the frames that the msfla contains
  # @morphemes: array of morphemes each of which contains
  #             frame-elements as well as its surface 
  #             representation
  attr_reader :xml, :doc 
  attr_reader :ids, :relations, :names, :morphemes
  
  def initialize(xml)
    @xml = xml
    #Document is a document class from REXML
    @doc = Document.new(@xml)
    parse
  end

  def parse
    morphemes = []
    frames    = []
    done = false
    @doc.root.each_element do |element|
      if element.name == "Styles"
        process_styles(element)
      end
      next if element.name != "Worksheet" or done
      element.each_element do |table|
        next if table.name != "Table"
        num_row = 0
        reference_row = []
        table.each_element do |row|
          next if row.name != "Row"
          case num_row
          when 0 #F-ID line, the very first element of XML
            @ids = make_id_array(row)
          when 1 # F-to-F relations line, the one that is
                 # to be converted to dot/graph
            @relations = make_f_array(row)
          when 2 # F-name, the third line of XML
            @names = make_f_array(row)
          else
            #row is the row under processing,
            #reference_row is the row from which the current
            #row obtains information of the multi-row-element
            #that it is a part of
            morph = make_morph(row, reference_row)
            morphemes << morph if morph
          end
          num_row += 1
        end
        done = true
      end
    end
    #gets rid of empty rows at the end of morphemes
    while morphemes[-1][0] == "" or nil
      morphemes.pop
    end
    @morphemes = morphemes
  end

  private

  #extracts style data of cells, 
  #i.e. position of borders and background color
  def process_styles(element)
    @styles = {}
    element.each_element do |s|
      id = s.attributes['ss:ID'].to_s
      @styles[id] = {:borders => [], :color => ""}
      s.each_element do |e|
        if e.name == 'Borders'
          e.each_element do |f|
            @styles[id][:borders] << f.attributes['ss:Position'].downcase
          end
        elsif e.name == 'Interior'
          @styles[id][:color] = e.attributes['ss:Color']
        end
      end
    end
  end

  #makes an array of elements from ID line
  def make_id_array(row)
    f_array = []
    first_cell = true
    #skip the first cell of the row; it contains nothing
    row.each_element do |cell|
      if first_cell
        first_cell = false
        next
      end
      if i = cell.elements[1]
        f_array << i.text
      end
    end
    return f_array
  end

  #makes an array of data from elements
  #in the row
  def make_f_array(row)
    index = 0
    f_array = []
    first_cell = true
    row.each_element do |cell|
      index += 1
      #ss:Index is the excel Excel's internal index
      #it could be different from our index, which
      #is given to each cell in the XML
      #that is, excel does not represent an empty cell
      #with an empty element, but just skip it only 
      #incrementing ss:Index
      idx = cell.attributes['ss:Index'].to_i
      df = idx - index
      if df > 0
        index = idx
        df.times do 
          f_array << ""
        end
      end    
      #skip the first cell of the row; it contains nothing
      if first_cell
        first_cell = false
        next
      end
      if cell.has_elements?
        data = ''
        phonetic = ''
        cell.each_element do |element|
          case element.name
          when 'Data'
            data = element.text
          #Excel's sheet internally contains phonetic data
          #of the text on the cell, i.e 'yomi' of the text
          when 'PhoneticText'
            #phonetic = ';' + element.text
            next
          end
        end
        f_array << data + phonetic
      #count in empty cells that could exist at the end
      #of each row
      elsif f_array.length < @ids.length
        f_array << ""
      end
    end
    return f_array
  end

  #makes an array of frame-element data for a given row
  #reference_row is (data of ) the row from which the 
  #currentrow obtains information of the multi-row-element
  #that it is a part of
  def make_morph(row, reference_row)
    index = 0
    morpheme = []
    column_index = 0
    row.each_element do |cell|
      id = cell.attributes['ss:StyleID'].to_s
      style = @styles[id]
      if style
        if style[:borders].empty?
          border = ""
        else 
          #border data is formated so that they are separated
          #with slashes
          border = style[:borders].join('/')
        end
        color = style[:color] unless column_index == 0
      end
      index += 1
      #ss:Index is the excel Excel's internal index
      #it could be different from our index, which
      #is given to each cell in the XML
      #that is, excel does not represent an empty cell
      #with an empty element, but just skip it only 
      #incrementing ss:Index      
      idx = cell.attributes['ss:Index'].to_i
      df = idx - index
      # when Excel's ss:Index and our index differ
      # we need to create an empty cell inheriting
      # the corresponding cell in the reference_row
      if df > 0
        index = idx 
        df.times do 
          data = reference_row[column_index] || ""
          morpheme << data
          #if the border data of the current element
          #contains "bottom", it means the next row
          #should not refer to a reference_row any more
          if /bottom/ =~ border
            reference_row[column_index] = ""
          else
            reference_row[column_index] = data 
          end
          column_index += 1
        end
      end
      #the actual retrieving of cell data starts from here
      #first, the case where the cell something useful 
      if cell.has_elements?
        data = ''
        phonetic = ''
        cell.each_element do |element|
          case element.name
          when 'Data'
            #skip comment rows
            if column_index == 0 and /^\s*(%%|#)/ =~ element.text
              return nil
            end
            #a data is composed of text and color that 
            #immediately follows it (optional)
            data = element.text + (color || "")
          #only when phonetic text is of any use...
          when 'PhoneticText'
            #phonetic = ';' + element.text
            next
          end
        end
        if data == ""
          data = reference_row[column_index] || ""
        end
        morpheme << data
        if /bottom/ =~ border || border == ""
          reference_row[column_index] = ""
        else
          reference_row[column_index] = data 
        end
      #the case we arrived at the end of the row
      #where empty cells are trailing
      elsif morpheme.length < @ids.length + 1
        data = reference_row[column_index] || ""
        morpheme << data
        if /bottom/ =~ border
          reference_row[column_index] = ""
        else
          reference_row[column_index] = data 
        end
      end
      column_index += 1
    end
    return morpheme
  end

  #called from make_dot method
  def make_relations(rel_text)
    relations = []
    if rel_text and rel_text != ""
      rel_array = []
      rel_array = rel_text.split(";")
      rel_array.each do |comma_connected|
        separated = comma_connected.split(",")
        separated.each_with_index do |element, i|
          if i > 0 and /\A\s*F\d+\s*\z/ =~ element
            relations << separated[0].sub(/\A\s*(.*)\s*F\d+\z/) { $1 + element }
          else
            relations << element.sub(/\A\s*(.*?)\s*\z/) {$1}
          end
        end
      end
    else
      relations << ""
    end
    return relations
  end
  
end # Class Msfa

#the below is just for a test purpose
if $0 == __FILE__
  require 'yaml'
  require 'kconv'
  file = ARGV[0]
  xml = File.read(file)
  msfa = Msfa.new(xml)
  File.open("test_result.txt", "w") do |f|
    f.write YAML.dump_stream(msfa.ids) + "\n\n"
    #f.write YAML.dump_stream(msfa.names) + "\n\n"
    f.write msfa.relations.to_yaml + "\n\n"
    #f.write msfa.morphemes + "\n\n"
  end
end
