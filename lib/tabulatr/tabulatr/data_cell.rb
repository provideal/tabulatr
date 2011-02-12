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

module Tabulatr::DataCell

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
  def data_column(name, opts={}, &block)
    raise "Not in data mode!" if @row_mode != :data
    opts = normalize_column_options opts
    make_tag(:td, opts[:td_html]) do
      href = if opts[:link].class == Symbol || opts[:link].class == String
          @view.send(opts[:link], @record)
        elsif opts[:link].respond_to?(:call)
          opts[:link].call(@record)
        else
          nil
        end
      make_tag((href ? :a : nil), :href => href) do
        if block_given?
          concat(yield(@record))
        else
          val = @record.send(opts[:method] || name)
          val = opts[:format].call(val) if opts[:format].is_a?(Proc)
          val = (opts[:format] % val)   if opts[:format].is_a?(String)
          val = Tabulatr::Formattr.format(opts[:format], val) if opts[:format].is_a?(Symbol)
          concat(val.to_s)
        end # block_given?
      end # </a>
    end # </td>
  end

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
  def data_association(relation, name, opts={}, &block)
    raise "Not in data mode!" if @row_mode != :data
    opts = normalize_column_options opts
    if block_given?
      return yield(@record)
    end
    assoc = @record.class.reflect_on_association(relation)
    make_tag(:td, opts[:td_html]) do
      concat(if assoc.collection?
        @record.send relation
      else
        [ @record.send(relation.to_sym) ]
      end.map do |r|
        val = r.send(opts[:method] || name)
        val = opts[:format].call(val) if opts[:format].class == Proc
        val = (opts[:format] % val)   if opts[:format].class == String
        val
      end.join(opts[:join_symbol]))
    end # </td>
  end

  def data_checkbox(opts={}, &block)
    raise "Whatever that's for!" if block_given?
    iname = "#{@classname}#{table_form_options[:checked_postfix]}[current_page][]"
    make_tag(:td, opts[:td_html]) do
      checked = @checked[:selected].member?(@record.id.to_s) ? :checked : nil
      make_tag(:input, :type => 'checkbox', :name => iname, 
        :value => @record.id, :checked => checked)
    end
  end

end

Tabulatr.send :include, Tabulatr::DataCell
