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

# These are extensions for use as a row builder
# In a seperate class call only for clearity
module Tabulatr::RowBuilder

  # called inside the build_table block, branches into data, header,
  # or filter building methods depending on the current mode
  def column(name, opts={}, &block)
    #puts "column: '#{name}'"
    case @row_mode
    when :data   then data_column(name, opts, &block)
    when :header then header_column(name, opts, &block)
    when :filter then filter_column(name, opts, &block)
    else raise "Wrong row mode '#{@row_mode}'"
    end # case
  end

  # called inside the build_table block, branches into data, header,
  # or filter building methods depending on the current mode
  def association(relation, name, opts={}, &block)
    #puts "assoc: '#{relation}.#{name}'"
    case @row_mode
    when :data   then data_association(relation, name, opts, &block)
    when :header then header_association(relation, name, opts, &block)
    when :filter then filter_association(relation, name, opts, &block)
    else raise "Wrong row mode '#{@row_mode}'"
    end # case
  end

  # called inside the build_table block, branches into data, header,
  # or filter building methods depending on the current mode
  def checkbox(opts={}, &block)
    #puts "column: '#{name}'"
    case @row_mode
    when :data   then data_checkbox(opts, &block)
    when :header then header_checkbox(opts, &block)
    when :filter then filter_checkbox(opts, &block)
    else raise "Wrong row mode '#{@row_mode}'"
    end # case
  end

private
  # returns self, sets record and row_mode as required for a
  # data row
  def data_row_builder(record)
    @record = record
    @row_mode = :data
    self
  end

  # returns self, sets record to nil and row_mode as required for a
  # header row
  def header_row_builder
    @record = nil
    @row_mode = :header
    self
  end

  # returns self, sets record to nil and row_mode as required for a
  # filter row
  def filter_row_builder
    @record = nil
    @row_mode = :filter
    self
  end

  # some preprocessing of the options
  def normalize_column_options(opts)
    opts = Tabulatr::COLUMN_OPTIONS.merge(opts)
    {:width => 'width', :align => 'text-align', :valign => 'vertical-align'}.each do |key,css|
      if opts[key]
        [:th_html, :filter_html, :td_html].each do |set|
          opts[set] ||= {}
          opts[set][:style] = (opts[set][:style] ? opts[set][:style] << "; " : "") << "#{css}: #{opts[key]}"
        end # each
      end # if
    end # each
    # more to come!
    opts
  end
end

Tabulatr.send :include, Tabulatr::RowBuilder