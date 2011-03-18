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

  # render the buttons to (de-)select multiple rows
  def render_select_controls
    make_tag(:div, :class => @table_options[:select_controls_div_class]) do
      iname = "#{@classname}#{TABLE_FORM_OPTIONS[:checked_postfix]}"
      @table_options[:select_controls].each do |name|
        raise "Invalid check control '#{name}' requested." unless [:select_all,
          :select_none, :select_visible, :unselect_visible,
          :select_filtered, :unselect_filtered].member?(name)
        topts = {
          :type => 'submit',
          :value => t(@table_options["#{name}_label"]),
          :name => "#{iname}[#{name}]" }
        topts[:class] = @table_options["#{name}_class"] if @table_options["#{name}_class"]
        make_tag(:input, topts)
      end
    end # </div>
  end

end