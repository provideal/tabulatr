# Builder class to define the data cells of a table
#
# Author::    Peter Horn, (mailto:peter.horn@provideal.net)
# Copyright:: Copyright (c) 2010 by Provideal Systems GmbH (http://www.provideal.net)
# License::   MIT, APACHE, Ruby, whatever, something free, ya know?
class TableBilder::TableDataCellsBuilder < TableBilder::TableAbstractCellsBuilder
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
  def column(name, opts={}, &block)
    opts = normalize_column_options opts
    if block_given?
      val = yield(@record)
    else
      val = @record.send(opts[:method] || name)
      val = opts[:format].call(val) if opts[:format].class == Proc
      val = (opts[:format] % val)   if opts[:format].class == String
    end
    @value << make_tag(:td, opts[:td_html]) << val << "</td>"
  end

  def set_action_view(av)
    @av = av
  end
end
