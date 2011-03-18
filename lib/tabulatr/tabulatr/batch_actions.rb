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

class Tabulatr

  # render the select tag or the buttons for batch actions
  def render_batch_actions
    make_tag(:div, :class => @table_options[:batch_actions_div_class]) do
      concat(t(@table_options[:batch_actions_label])) if @table_options[:batch_actions_label]
      iname = "#{@classname}#{TABLE_FORM_OPTIONS[:batch_postfix]}"
      case @table_options[:batch_actions_type]
      when :select
        make_tag(:select, :name => iname, :class => @table_options[:batch_actions_class]) do
          concat("<option></option>")
          @table_options[:batch_actions].each do |n,v|
            make_tag(:option, :value => n) do
              concat(v)
            end # </option>
          end # each
        end # </select>
      when :buttons
        @table_options[:batch_actions].each do |n,v|
          make_tag(:input, :type => 'submit', :value => v, 
            :name => "#{iname}[#{n}]",
            :class => @table_options[:batch_actions_class])
        end # each
      else raise "Use either :select or :buttons for :batch_actions_type"
      end # case
    end # </div>
  end
  
end