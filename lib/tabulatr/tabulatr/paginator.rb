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
    make_tag(:div, :class => @table_options[:paginator_div_class]) do
      # << Page Left
      if page > 1
        make_tag(:input, :type => 'image', 
          :src => File.join(@table_options[:image_path_prefix], @table_options[:pager_left_button]),
          :class => @table_options[:page_left_class],
          :name => "#{pagination_name}[page_left]")
      else
        make_tag(:img, 
          :src => File.join(@table_options[:image_path_prefix], @table_options[:pager_left_button_inactive]),
          :class => @table_options[:page_left_class])
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
        make_tag(:input, :type => 'image', 
          :src => File.join(@table_options[:image_path_prefix], @table_options[:pager_right_button]),
          :class => @table_options[:page_right_class],
          :name => "#{pagination_name}[page_right]")
      else
        make_tag(:img, :src => File.join(@table_options[:image_path_prefix], @table_options[:pager_right_button_inactive]),
          :class => @table_options[:page_right_class])
      end  # page < pages
      if pagesizes.length > 1
        make_tag(:select, :name => "#{pagination_name}[pagesize]", :class => @table_options[:pagesize_select_class]) do
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

end