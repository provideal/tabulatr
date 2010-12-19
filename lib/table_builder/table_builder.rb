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

  TABLE_DESIGN_OPTIONS = {
    :sortable_class => 'sortable',
    :sorting_asc => 'sort-asc',
    :sorting_desc => 'sorting-desc',
    :page_left => 'page-left',
    :page_right => 'page-right',
    :page_nr => 'page-nr'
    :control_div_id => 'table-controls'
    :paginator_div_id => 'paginator',
    :batch_actions_div_id => 'batch-actions',
    :batch_actions_name => 'batch_action',
    :sort_by_name => 'sort_by_name'
    # zillions of things
  }
  
  # Hash keeping the defaults for the table options
  TABLE_OPTIONS = {
    :table_html => false,    # a hash with html attributes for the table
    :row_html => false,      # a hash with html attributes for the normal trs
    :header_html => false,   # a hash with html attributes for the header trs
    :filter_html => false,   # a hash with html attributes for the filter trs
    :filter => true,         # false for no filter row at all
    :paginate => false,      # true to show paginator 
    :sort => false,          # true to allow sorting
    :make_form => true,
    :action => nil,
    :method => 'post',
    :batch_actions => false  # name => value hash of batch action stuff
    #...
  }

  # Hash keeping the defaults for the column options
  COLUMN_OPTIONS = {
    :header => false,        # a string to write into the header cell
    :width => false,         # the width of the cell
    :align => false,         # horizontal alignment
    :valign => false,        # vertical alignment
    :wrap => true,           # wraps
    :type => :string,        # :integer, :date
    :td_html => false,       # a hash with html attributes for the cells
    :th_html => false,       # a hash with html attributes for the header cell
    :filter_html => false,   # a hash with html attributes for the filter cell
    :filter_html => false,   # a hash with html attributes for the filter cell
    :filter => true,         # false for no filter field, array-of-names, hash-of-names-values for select, ClassName for foreign keys
    :filter_like => false,   # true to filter w/ like %?%
    :format => false,        # a sprintf-string or a proc to do special formatting
    :method => false,        # if you want to get the column by a different method than its name
    :sortable => false       # if set, sorting-stuff is added to the header cell
  }

  # Constructor of TableBuilder
  #
  # Parameters:
  # <tt>records</tt>:: the 'row' data of the table
  # <tt>view</tt>:: the current instance of ActionView
  # <tt>opts</tt>:: a hash of options specific for this table
  def initialize(records, view, opts={}) 
    @records = records
    @view = view
    @opts = TABLE_OPTIONS.merge opts
    @val = []
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
  def build_table(&block)
    @val = []
    @val << "<div id=\"#{TABLE_OPTIONS[:action_div_id]}\">"
    # FIXME: table options and stuff
    @val << "<form method=\"get\">" if @opts[:make_form] 
    render_sort_field if @opts[:sortable] 
    render_paginator if @opts[:paginate]
    render_batch_actions if @opts[:batch_actions]
    @val << '</div>'
    
    @val << make_tag(:table, @opts[:table_html])
    @val << make_tag(:thead)

    render_table_header
    render_table_filters if @opts[:filter]

    @val << "</thead>\n<!-- Body -->\n<tbody>"

    # Data Rows
    render_table_rows
    
    @val << "</tbody></table>"
    @val << '</form>' if @opts[:make_form] 
    @val.join("\n")
  end
  
private
  # render the hidden input field that containing the current sort key
  def render_sort_field
    @val << '<!-- Sort Field begin -->'
    # FIXME take 'current' value
    @val << "<input type=\"hidden\" name=\"#{TABLE_DESIGN_OPTIONS[:sort_by_name]}\" value=\"\" />"
    @val << '<!-- Sort Field end -->'
  end

  #render the paginator controls, inputs etc.
  def render_paginator
    @val << "\n<div id=\"#{TABLE_DESIGN_OPTIONS[:paginator_div_id]}\">"
    @val << "<a href=\"\#\" id= \"page-left\" class=\"#{TABLE_DESIGN_OPTIONS[:page_left]}\">&laquo;</a>"
    # FIXME find current page number
    @val << "<input type=\"text\" id=\"page-nr\" class=\"#{TABLE_DESIGN_OPTIONS[:page_nr]}\" value=\"\" />"
    # FIXME find total number of pages
    @val << "/..."
    @val << "<a href=\"\#\" id= \"page-right\" class=\"#{TABLE_DESIGN_OPTIONS[:page_left]}\">&raquo;</a>"
    # FIXME attach js actions to pager controls
    @val << "</div>\n"
  end

  # render the select tag for batch actions
  def render_batch_actions
    @val << "\n<div id=\"#{TABLE_OPTIONS[:batch_actions_div_id]}\">"
    @val << "<select name=\"#{TABLE_OPTIONS[:batch_actions_name]}\" id=\"#{TABLE_OPTIONS[:batch_actions_name]}\">"
    @opts[:batch_actions].each do |n,v|
      @val << "<option value=\"#{v}\">#{h}</option>"
    end
    @val << "</select>"
    # FIXME add js trigger stuff if appropriate
    @val << "</div>\n"
  end
  
  # render the header row
  def render_table_header
    @val << "<!-- Header -->"
    @val << make_tag(:tr, @opts[:header_html])
    header_builder = TableHeaderCellsBuilder.new(nil, @opts)
    yield(header_builder)
    @val << header_builder.value
    @val << "</tr>"
  end
  
  # render the filte row
  def render_table_filters
    @val << "<!-- Filter -->"
    @val << make_tag(:tr, @opts[:filter_html])
    filter_builder = TableFilterCellsBuilder.new(nil, @opts)
    yield(filter_builder)
    @val << filter_builder.value
    @val << '</tr>'
  end
  
  # render the table rows
  def render_table_rows
    tr = make_tag(:tr, @opts[:row_html])
    @records.each_with_index do |record, i|
      @val << "<!-- Row #{i} -->"
      row_builder = TableDataCellsBuilder.new(record, @opts)
      row_builder.set_action_view(@view)
      yield(row_builder)
      @val << tr << row_builder.value << "</tr>"
    end
  end
  
  # stringly produce a tag w/ some options
  def self.make_tag(tag, hash={})
    hash ||= {}
    hash.inject("<#{tag}") do |s,h|
      s << " #{h[0]}=\"#{h[1]}\""
    end << ">"
  end
end

# These are extensions for use from ActionController instances
# In a seperate class call only for clearity
class TableBuilder
  PAGINATE_OPTIONS = {
    :per_page => 10
    :page => 1
    # more...
  }
  PAGINATE_NAME = :pagination
  FILTER_NAME   = :filter
  SORT_NAME     = :sort_by

  def self.get_table_options(params, opts={})
    val = {}
    val[:paginate] = PAGINATE_OPTIONS.merge(opts).merge(params[PAGINATE_NAME] || {})
    val[:filter] = params[FILTER_NAME].inject(["(1=1) ", []]) do |c, t|
      n, v = t
      # FIXME n = name_escaping(n)
      if (params["#{FILTER_NAME}_matcher".to_sym] || {})[n]=='like' 
        m = 'like' 
        v = "%#{v}%"
      else m = '=' end
      [c[0] << "AND (`#{n}` #{m} ?) ", c[1] << v]
    end
    # FIXME escaping!!!
    val[:sort_by] = '...'
    val
  end
  
end
