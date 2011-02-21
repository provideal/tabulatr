#--
# Copyright (c) 2010-2011 Peter Horn, Provideal GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

# Tabulatr is a class to allow easy creation of data tables as you
# frequently find them on 'index' pages in rails. The 'table convention'
# here is that we consider every table to consist of three parts:
# * a header containing the names of the attribute of the column
# * a filter which is an input element to allow for searching the
#   particular attribute
# * the rows with the actual data.
#
# Additionally, we expect that people want to 'select' rows and perform
# batch actions on these rows.
#
# Author::    Peter Horn, (mailto:peter.horn@provideal.net)
# Copyright:: Copyright (c) 2010-2011 by Provideal GmbH (http://www.provideal.net)
# License::   MIT Licence
class Tabulatr

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TranslationHelper

  # Constructor of Tabulatr
  #
  # Parameters:
  # <tt>records</tt>:: the 'row' data of the table
  # <tt>view</tt>:: the current instance of ActionView
  # <tt>opts</tt>:: a hash of options specific for this table
  def initialize(records, view=nil, toptions={})
    @records = records
    @view = view
    @table_options = TABLE_OPTIONS.merge(toptions)
    @val = []
    @record = nil
    @row_mode = false
    @classname = @records.send(FINDER_INJECT_OPTIONS[:classname])
    @pagination = @records.send(FINDER_INJECT_OPTIONS[:pagination])
    @filters = @records.send(FINDER_INJECT_OPTIONS[:filters])
    @sorting = @records.send(FINDER_INJECT_OPTIONS[:sorting])
    @checked = @records.send(FINDER_INJECT_OPTIONS[:checked])
    @should_translate = @table_options[:translate]
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
    make_tag(@table_options[:make_form] ? :form : nil,
        :method => :get,
        :class => TABLE_DESIGN_OPTIONS[:form_class],
        'data-remote' => (TABLE_DESIGN_OPTIONS[:remote] ? "true" : nil)) do
      make_tag(:div,  :class => TABLE_DESIGN_OPTIONS[:control_div_class]) do
        # FIXME: table options and stuff
        #render_sort_field if @table_options[:sortable]
        render_paginator if @table_options[:paginate]
        render_batch_actions if @table_options[:batch_actions]
        if @table_options[:make_form]
          make_tag(:input, :type => 'submit',
            :class => TABLE_DESIGN_OPTIONS[:submit_class],
            :value => t(TABLE_DESIGN_OPTIONS[:submit_label]))
        end
        render_check_controls if @table_options[:check_controls]
        make_tag(:div, :class => TABLE_DESIGN_OPTIONS[:info_text_class]) do
          # :info_text => "Showing %1$d, total %2$d, selected %3$d, matching %4$d"
          concat(format(t(TABLE_DESIGN_OPTIONS[:info_text]),
            @records.count, @pagination[:total], @checked[:selected].length, @pagination[:count]))
        end if TABLE_DESIGN_OPTIONS[:info_text]
      end # </div>'

      to = @table_options[:table_html]
      to = (to || {}).merge(:class => TABLE_DESIGN_OPTIONS[:table_class]) if TABLE_DESIGN_OPTIONS[:table_class]
      make_tag(:table, to) do
        make_tag(:thead) do
          render_table_header(&block)
          render_table_filters(&block) if @table_options[:filter]
        end # </thead>
        make_tag(:tbody) do
          render_table_rows(&block)
        end # </tbody>
      end # </table>
    end # </form>
    @val.join("").html_safe
  end

  def self.finder_inject_options(n=nil)
    FINDER_INJECT_OPTIONS.merge!(n) if n
    FINDER_INJECT_OPTIONS
  end
  def finder_inject_options(n=nil) self.class.finder_inject_options(n) end

  def self.column_options(n=nil)
    COLUMN_OPTIONS.merge!(n) if n
    COLUMN_OPTIONS
  end
  def column_options(n=nil) self.class.column_options(n) end

  def self.table_options(n=nil)
    TABLE_OPTIONS.merge!(n) if n
    TABLE_OPTIONS
  end
  def table_options(n=nil) self.class.table_options(n) end

  def self.paginate_options(n=nil)
    PAGINATE_OPTIONS.merge!(n) if n
    PAGINATE_OPTIONS
  end
  def paginate_options(n=nil) self.class.paginate_options(n) end

  def self.table_form_options(n=nil)
    TABLE_FORM_OPTIONS.merge!(n) if n
    TABLE_FORM_OPTIONS
  end
  def table_form_options(n=nil) self.class.table_form_options(n) end

  def self.table_design_options(n=nil)
    TABLE_DESIGN_OPTIONS.merge!(n) if n
    TABLE_DESIGN_OPTIONS
  end
  def table_design_options(n=nil) self.class.table_design_options(n) end

private
  # either append to the internal string buffer or use
  # ActionView#concat to output if an instance is available.
  def concat(s, html_escape=false)
    #@view.concat(s) if (Rails.version.to_f < 3.0 && @view)
    #puts "\##{Rails.version.to_f} '#{s}'"
    if s.present? then @val << (html_escape ? h(s) : s) end
  end

  def h(s)
    ERB::Util.h(s)
  end

  def t(s)
    return '' unless s.present?
    begin
      if s.respond_to?(:should_localize?) and s.should_localize?
        translate(s)
      else
        case @should_translate
        when :translate then translate(s)
        when true then translate(s)
        when :localize then localize(s)
        else
          if !@should_translate
            s
          elsif @should_translate.respond_to?(:call)
            @should_translate.call(s)
          else
            raise "Wrong value '#{@should_translate}' for table option ':translate', should be false, true, :translate, :localize or a proc."
          end
        end
      end
    rescue
      raise "Translating '#{s}' failed!"
    end
  end

  #render the paginator controls, inputs etc.
  def render_paginator
    # get the current pagination state
    pagination_name = "#{@classname}#{TABLE_FORM_OPTIONS[:pagination_postfix]}"
    pparams = @records.send(FINDER_INJECT_OPTIONS[:pagination])
    page = pparams[:page].to_i
    pages = pparams[:pages].to_i
    pagesize = pparams[:pagesize].to_i
    pagesizes = pparams[:pagesizes].map &:to_i
    # render the 'wrapping' div
    make_tag(:div, :class => TABLE_DESIGN_OPTIONS[:paginator_div_class]) do
      # << Page Left
      if page > 1
        make_tag(:input, :type => 'image', :src => TABLE_DESIGN_OPTIONS[:pager_left_button],
          :class => TABLE_DESIGN_OPTIONS[:page_left_class],
          :name => "#{pagination_name}[page_left]")
      else
        make_tag(:img, :src => TABLE_DESIGN_OPTIONS[:pager_left_button_inactive],
          :class => TABLE_DESIGN_OPTIONS[:page_left_class])
      end  # page > 1
      # current page number
      concat(make_tag(:input,
        :type => :hidden,
        :name => "#{pagination_name}[current_page]",
        :value => page))
      concat(make_tag(:input,
        :type => :text,
        :size => pages.to_s.length,
        :name => "#{pagination_name}[page]",
        :value => page))
      concat("/#{pages}")
      # >> Page Right
      if page < pages
        make_tag(:input, :type => 'image', :src => TABLE_DESIGN_OPTIONS[:pager_right_button],
          :class => TABLE_DESIGN_OPTIONS[:page_right_class],
          :name => "#{pagination_name}[page_right]")
      else
        make_tag(:img, :src => TABLE_DESIGN_OPTIONS[:pager_right_button_inactive],
          :class => TABLE_DESIGN_OPTIONS[:page_right_class])
      end  # page < pages
      if pagesizes.length > 1
        make_tag(:select, :name => "#{pagination_name}[pagesize]", :class => TABLE_DESIGN_OPTIONS[:pagesize_select_class]) do
          pagesizes.each do |n|
            make_tag(:option, (n.to_i==pagesize ? {:selected  => :selected} : {}).merge(:value => n)) do
              concat(n.to_s)
            end # </option>
          end # each
        end # </select>
      else # just one pagesize
        concat(make_tag(:input,
          :type => :hidden,
          :name => "#{pagination_name}[pagesize]",
          :value => pagesizes.first))
      end
    end # </div>
  end

  # render the select tag for batch actions
  def render_batch_actions
    make_tag(:div, :class => TABLE_DESIGN_OPTIONS[:batch_actions_div_class]) do
      concat(t(TABLE_DESIGN_OPTIONS[:batch_actions_label])) if TABLE_DESIGN_OPTIONS[:batch_actions_label]
      iname = "#{@classname}#{TABLE_FORM_OPTIONS[:batch_postfix]}"
      make_tag(:select, :name => iname, :id => TABLE_OPTIONS[:batch_actions_name]) do
        concat("<option></option>")
        @table_options[:batch_actions].each do |n,v|
          make_tag(:option, :value => n) do
            concat(v)
          end # </option>
        end # each
      end # </select>
    end # </div>
  end

  def render_check_controls
    make_tag(:div, :class => TABLE_DESIGN_OPTIONS[:check_controls_div_class]) do
      iname = "#{@classname}#{TABLE_FORM_OPTIONS[:checked_postfix]}"
      make_tag(:input, :type => 'submit', :value => t(TABLE_DESIGN_OPTIONS[:select_all_label]), :name => "#{iname}[select_all]")
      make_tag(:input, :type => 'submit', :value => t(TABLE_DESIGN_OPTIONS[:select_none_label]), :name => "#{iname}[select_none]")
      make_tag(:input, :type => 'submit', :value => t(TABLE_DESIGN_OPTIONS[:select_visible_label]), :name => "#{iname}[select_visible]")
      make_tag(:input, :type => 'submit', :value => t(TABLE_DESIGN_OPTIONS[:unselect_visible_label]), :name => "#{iname}[unselect_visible]")
      make_tag(:input, :type => 'submit', :value => t(TABLE_DESIGN_OPTIONS[:select_filtered_label]), :name => "#{iname}[select_filtered]")
      make_tag(:input, :type => 'submit', :value => t(TABLE_DESIGN_OPTIONS[:unselect_filtered_label]), :name => "#{iname}[unselect_filtered]")
    end # </div>
  end

  # render the header row
  def render_table_header(&block)
    make_tag(:tr, @table_options[:header_html]) do
      yield(header_row_builder)
    end # </tr>"
  end

  # render the filter row
  def render_table_filters(&block)
    make_tag(:tr, @table_options[:filter_html]) do
      yield(filter_row_builder)
    end # </tr>
  end

  # render the table rows
  def render_table_rows(&block)
    row_classes = @table_options[:row_classes] || []
    row_html = @table_options[:row_html] || {}
    row_class = row_html[:class] || ""
    @records.each_with_index do |record, i|
      concat("<!-- Row #{i} -->")
      if row_classes.present?
        rc = row_class.present? ? row_class + " " : ''
        rc += row_classes[i % row_classes.length]
      else
        rc = nil
      end
      make_tag(:tr, row_html.merge(:class => rc)) do
        yield(data_row_builder(record))
      end # </tr>
    end
  end

  # stringly produce a tag w/ some options
  def make_tag(name, hash={}, &block)
    attrs = hash ? tag_options(hash) : ''
    if block_given?
      if name
        concat("<#{name}#{attrs}>")
        yield
        concat("</#{name}>")
      else
        yield
      end
    else
      concat("<#{name}#{attrs} />")
    end
    nil
  end
end

Dir[File.dirname(__FILE__) + "/tabulatr/*.rb"].each do |file|
  #puts file
  require file
end
