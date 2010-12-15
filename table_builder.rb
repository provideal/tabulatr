# TableBuilder is a class to allow easy creation of data tables as you
# frequently find them on 'index' pages in rails. The 'table convention'
# here is that we consider every table to consist of three parts:
# * a header containing the names of the attribute of the column
# * a filter which is an input element to allow for searching the
#   particular attribute
# * the rows with the actual data.
#
# Author::    Peter Horn, (mailto:peter.horn@provideal.net)
# Copyright:: Copyright (c) 2010 by Provideal Systems GmbH (http://www.provideal.net)
# License::   MIT, APACHE, Ruby, whatever, something free, ya know?

class TableBuilder

  # Hash keeping the defaults for the table options
  TABLE_OPTIONS = {
    :table_html => false,    # a hash with html attributes for the table
    :row_html => false,      # a hash with html attributes for the normal trs
    :header_html => false,   # a hash with html attributes for the header trs
    :filter_html => false,   # a hash with html attributes for the filter trs
    :filter => true          # false for no filter row at all
  }

  # Hash keeping the defaults for the column options
  COLUMN_OPTIONS = {
    :header => false,        # a string to write into the header cell
    :type => :string,        # :integer, :date
    :td_html => false,       # a hash with html attributes for the cells
    :th_html => false,       # a hash with html attributes for the header cell
    :filter_html => false,   # a hash with html attributes for the filter cell
    :filter_html => false,   # a hash with html attributes for the filter cell
    :filter => true,         # false for no filter field, array-of-names, hash-of-names-values for select, ClassName for foreign keys
    :filter_match => :equal, # :like
    :format => false,        # a sprintf-string or a proc to do special formatting
    :method => false         # if you want to get the column by a different method than its name
  }

  # Builder base class used internally
  class TableAbstractBuilder
    # constructor taking the record which is to be output (or nil if 
    # n/a) and a hash of options
    def initialize(record, opts={})
      @record = record
      @opts = opts
      @value = []
    end

    # the method used to actually define the columns, taking the name
    # of the attribute and a hash of options
    def column(name, opts={})
      raise "implement me!"
    end

    # return the actual rendered html for the builder
    def value
      @value.join ""
    end

    # helper to define a tag. 
    # Should be replaced by a/the standard Rails helper
    def make_tag(tag, hash={})
      hash ||= {}
      hash.inject("<#{tag}") do |s,h|
        s << " #{h[0]}=\"#{h[1]}\""
      end << ">"
    end
  end

  # builder class to define the header cells of a table
  class TableHeaderCellsBuilder < TableAbstractBuilder
    # the method used to actually define the headers of the columns, 
    # taking the name of the attribute and a hash of options. 
    #
    # The following options are evaluated here:
    # <tt>:th_html</tt>:: a hash with html-attributes added to the <th>s created
    # <tt>:header</tt>:: if present, the value will be output in the header cell,
    #                    otherwise, the capitalized name is used
    def column(name, opts={})
      opts = COLUMN_OPTIONS.merge opts
      @value << make_tag(:th, opts[:th_html]) << (opts[:header] || name.to_s.capitalize) << "</th>"
    end
  end

  # builder class to define the filter cells of a table
  class TableFilterCellsBuilder < TableAbstractBuilder
    # the method used to actually define the filters of the columns, 
    # taking the name of the attribute and a hash of options. 
    #
    # The following options are evaluated here:
    # <tt>:filter_html</tt>:: a hash with html-attributes added to the <ts>s created
    # <tt>:filter</tt>:: may take different values:
    #                    <tt>false</tt>:: no filter is output for this column
    #                    a Hash:: the keys of the hash are used to define a <tt>select</tt>
    #                             where the values are the <tt>value</tt> of the <tt>options</tt>.
    #                    an Array:: the elements of that array are used to define a
    #                               <tt>select</tt>
    #                    a subclass of <tt>ActiveRecord::Base</tt>:: a <tt>select</tt> is created
    #                                                                with all instances
    def column(name, opts={})
      opts = COLUMN_OPTIONS.merge opts
      @value << make_tag(:td, opts[:filter_html])
      v = if !opts[:filter]
        ""
      elsif opts[:filter].class == Hash
        opts[:filter].inject("<select name=\"filter[#{name}]\">") do |s,p|
          s << "<option value=\"#{p[1]}\">#{p[1]}</option>"
        end << "</select>"
      elsif opts[:filter].class == Array
        opts[:filter].inject("<select name=\"filter[#{name}]\">") do |s,p|
          s << "<option value=\"#{p}\">#{p}</option>"
        end << "</select>"
      elsif opts[:filter].class == Class
        raise "Implement me: '#{opts[:filter]}'"
      else
        make_tag(:input, :type => :text, :name => "filter[#{name}]") << "</input>"
      end
      @value << v << "</td>"
    end
  end

  # builder class to define the data cells of a table
  class TableDataCellsBuilder < TableAbstractBuilder
    # the method used to actually define the data cells of the columns, 
    # taking the name of the attribute and a hash of options. 
    #
    # The following options are evaluated here:
    # <tt>:td_html</tt>:: a hash with html-attributes added to the <ts>s created
    # <tt>:method</tt>:: the actual method invoked on the record to retrieve the
    #                    value for the column, or false if name is to be used.
    # <tt>:fromat</tt>:: either a String by which the value is <tt>sprinf</tt>ed,
    #                    a proc/lambda to which the value is passed or false if
    #                    no specific formatting is desired.
    def column(name, opts={})
      opts = COLUMN_OPTIONS.merge opts
      val = @record.send(opts[:method] || name)
      val = opts[:format].call(val) if opts[:format].class == Proc
      val = (opts[:format] % val)   if opts[:format].class == String
      @value << make_tag(:td, opts[:td_html]) << val << "</td>"
    end
  end

  # the actual table definition method. It takes an Array of records, a hash of 
  # options and a block with the actual <tt>column</tt> calls.
  #
  # The following options are evaluated here:
  # <tt>:table_html</tt>:: a hash with html-attributes added to the <table> created
  # <tt>:header_html</tt>:: a hash with html-attributes added to the <tr> created
  #                         for the header row
  # <tt>:filter_html</tt>:: a hash with html-attributes added to the <tr> created
  #                         for the filter row
  # <tt>:row_html</tt>:: a hash with html-attributes added to the <tr>s created
  #                      for the data rows
  # <tt>:filter</tt>:: if set to false, no filter row is output
  def self.build_table(records, opts={}, &block)
    opts = TABLE_OPTIONS.merge opts
    val = [make_tag(:table, opts[:table_html])]
    val << make_tag(:thead)

    # Header
    val << "<!-- Header -->"
    val << make_tag(:tr, opts[:header_html])
    header_builder = TableHeaderCellsBuilder.new(nil)
    yield(header_builder)
    val << header_builder.get_value
    val << "</tr>"

    # Filter
    if opts[:filter]
      val << "<!-- Filter -->"
      val << make_tag(:tr, opts[:filter_html])
      filter_builder = TableFilterCellsBuilder.new(nil)
      yield(filter_builder)
      val << filter_builder.get_value
      val << '</tr>'
    end
    val << "</thead>\n<!-- Body -->\n<tbody>"

    # Data Rows
    tr = make_tag(:tr, opts[:row_html])
    records.each_with_index do |record, i|
      val << "<!-- Row #{i} -->"
      row_builder = TableDataCellsBuilder.new(record)
      yield(row_builder)
      val << tr << row_builder.get_value << "</tr>"
    end
    val << "</tbody></table>"
    val.join("\n")
 end

 def self.make_tag(tag, hash={})
   hash ||= {}
   hash.inject("<#{tag}") do |s,h|
     s << " #{h[0]}=\"#{h[1]}\""
   end << ">"
 end
end
