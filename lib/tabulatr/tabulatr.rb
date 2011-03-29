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
    @table_form_options = TABLE_FORM_OPTIONS
    @val = []
    @record = nil
    @row_mode = false
    @classname = @records.send(FINDER_INJECT_OPTIONS[:classname])
    @pagination = @records.send(FINDER_INJECT_OPTIONS[:pagination])
    @filters = @records.send(FINDER_INJECT_OPTIONS[:filters])
    @sorting = @records.send(FINDER_INJECT_OPTIONS[:sorting])
    @checked = @records.send(FINDER_INJECT_OPTIONS[:checked])
    @store_data = @records.send(FINDER_INJECT_OPTIONS[:store_data])
    @stateful = @records.send(FINDER_INJECT_OPTIONS[:stateful])
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
        :class => @table_options[:form_class],
        'data-remote' => (@table_options[:remote] ? "true" : nil)) do
      # TODO: make_tag(:input, :type => 'submit', :style => 'display:inline; width:1px; height:1px', :value => '__submit')
      make_tag(:div,  :class => @table_options[:control_div_class_before]) do
        @table_options[:before_table_controls].each do |element|
          render_element(element)
        end
      end if @table_options[:before_table_controls].present? # </div>

      @store_data.each do |k,v|
        make_tag(:input, :type => :hidden, :name => k, :value => h(v))
      end

      render_element(:table, &block)

      make_tag(:div,  :class => @table_options[:control_div_class_after]) do
        @table_options[:after_table_controls].each do |element|
          render_element(element)
        end
      end if @table_options[:after_table_controls].present? # </div>

    end # </form>
    @val.join("").html_safe
  end

  def render_element(element, &block)
    case element
    when :paginator then render_paginator if @table_options[:paginate]
    when :hidden_submit then "IMPLEMENT ME!"
    when :submit then   make_tag(:input, :type => 'submit',
        :class => @table_options[:submit_class],
        :value => t(@table_options[:submit_label]))
    when :reset then   make_tag(:input, :type => 'submit',
        :class => @table_options[:reset_class],
        :name => "#{@classname}#{TABLE_FORM_OPTIONS[:reset_state_postfix]}",
        :value => t(@table_options[:reset_label])) if @stateful
    when :batch_actions then render_batch_actions if @table_options[:batch_actions]
    when :select_controls then render_select_controls if @table_options[:selectable]
    when :info_text
      make_tag(:div, :class => @table_options[:info_text_class]) do
        concat(format(t(@table_options[:info_text]),
          @records.count, @pagination[:total], @checked[:selected].length, @pagination[:count]))
      end if @table_options[:info_text]
    when :table then render_table &block
    else
      if element.is_a?(String)
        concat(element)
      else
        raise "unknown element '#{element}'"
      end
    end
  end

  def render_table(&block)
    to = @table_options[:table_html]
    to = (to || {}).merge(:class => @table_options[:table_class]) if @table_options[:table_class]
    make_tag(:table, to) do
      make_tag(:thead) do
        render_table_header(&block)
        render_table_filters(&block) if @table_options[:filter]
      end # </thead>
      make_tag(:tbody) do
        render_table_rows(&block)
      end # </tbody>
    end # </table>
  end

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
      #concat("<!-- Row #{i} -->")
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

Dir[File.join(File.dirname(__FILE__), "tabulatr", "*.rb")].each do |file|
  require file
end
