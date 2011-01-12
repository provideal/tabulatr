# These are extensions for use as a row builder
# In a seperate class call only for clearity
module TableBuilder::RowBuilder

  # called inside the build_table block, branches into data, header,
  # or filter building methods depending on the current mode
  def column(name, opts={}, &block)
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
    case @row_mode
    when :data   then data_association(relation, name, opts, &block)
    when :header then header_association(relation, name, opts, &block)
    when :filter then filter_association(relation, name, opts, &block)
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
    opts = TableBuilder::COLUMN_OPTIONS.merge(opts)
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

TableBuilder.send :include, TableBuilder::RowBuilder