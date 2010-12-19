# Builder base class used internally
#
# Author::    Peter Horn, (mailto:peter.horn@provideal.net)
# Copyright:: Copyright (c) 2010 by Provideal Systems GmbH (http://www.provideal.net)
# License::   MIT, APACHE, Ruby, whatever, something free, ya know?
class TableBilder::TableAbstractCellsBuilder
  # constructor taking the record which is to be output (or nil if
  # n/a) and a hash of options
  def initialize(record, opts={})
    @record = record
    @opts = opts
    @value = []
  end

  # the method used to actually define the columns, taking the name
  # of the attribute and a hash of options.
  # If block is given, it's evaluated for the data cells.
  def column(name, opts={}, &block)
    raise "implement me!"
  end

  # return the actual rendered html for the builder
  def value
    @value.join ""
  end

  # some preprocessing of the options
  def normalize_column_options(opts)
    opts = COLUMN_OPTIONS.merge(opts)
    [:width => 'width', :align => 'text-align', :valign => 'ads']
    if opts[:width]
      [:th_html, :filter_html, :td_html].each do |key|
        opts[key] ||= {}
        opts[key][:style] = (opts[key][:style] ? opts[key][:style] << "; " : "") << "width: #{opts[:width]}"
      end
    end
    # more to come!
    opts
  end

  # helper to define a tag.
  # Should be replaced by a/the standard Rails helper
  def make_tag(tag, hash={}, &block)
    hash ||= {}
    s = hash.inject("<#{tag}") do |s,h|
      s << " #{h[0]}=\"#{h[1]}\""
    end << ">"
  end
end
