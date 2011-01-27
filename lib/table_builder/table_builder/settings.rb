class TableBuilder #::Settings

  # these settings are considered constant for the whole application, can not be overridden
  # on a per-table basis
  TABLE_DESIGN_OPTIONS = {
    :sortable => 'sortable',                    # class for the header of a sortable column
    :sorting_asc => 'sort-asc',                 # class for the currently asc sorting column
    :sorting_desc => 'sorting-desc',            # class for the currently desc sorting column
    :page_left_id => 'page-left',               # id for the page left <a>
    :page_right_id => 'page-right',             # id for the page right <a>
    :page_no_id => 'page-no',                   # id for the page no <input>
    :control_div_id => 'table-controls',        # id of the div containing the paging and batch action controls
    :paginator_div_id => 'paginator',           # id of the div containing the paging controls
    :batch_actions_div_id => 'batch-actions'    # id of the dic containing the batch action controls
  }

  TABLE_FORM_OPTIONS = {
    :make_form => true,                         # whether or not to wrap the whole table (incl. controls) in a form
    :batch_action_name => 'batch_action',       # name of the batch action param
    :sort_by_key => 'sort_by_key',              # name of key which to search, format is 'id asc'
    :pagination_name => 'pagination',           # name of the param w/ the pagination infos
    :filter_name => 'filter',                   # name of the filter in the params hash: xxx_filter
    :method => 'post'                           # http method for that form if applicable
  }

  PAGINATE_OPTIONS = {
    :page => 1,
    :pagesize => 10,
    :pagesizes => [10, 20, 50]
  }

  # Hash keeping the defaults for the table options, may be overriden in the
  # table_for call
  TABLE_OPTIONS = {
    :table_html => false,        # a hash with html attributes for the table
    :row_html => false,          # a hash with html attributes for the normal trs
    :header_html => false,       # a hash with html attributes for the header trs
    :filter_html => false,       # a hash with html attributes for the filter trs
    :filter => true,             # false for no filter row at all
    :paginate => false,          # true to show paginator
    :sortable => false,          # true to allow sorting (can be specified for every sortable column)
    :action => nil,              # target action of the wrapping form if applicable
    :batch_actions => false,     # name => value hash of batch action stuff
    :join_symbol => ', '         # symbol used to join the elements of 'many' associations
  }

  # Hash keeping the defaults for the column options
  COLUMN_OPTIONS = {
    :header => false,                   # a string to write into the header cell
    :width => false,                    # the width of the cell
    :align => false,                    # horizontal alignment
    :valign => false,                   # vertical alignment
    :wrap => true,                      # wraps
    :type => :string,                   # :integer, :date
    :td_html => false,                  # a hash with html attributes for the cells
    :th_html => false,                  # a hash with html attributes for the header cell
    :filter_html => false,              # a hash with html attributes for the filter cell
    :filter_html => false,              # a hash with html attributes for the filter cell
    :filter => true,                    # false for no filter field,
                                        # container for options_for_select
                                        # String from options_from_collection_for_select or the like
                                        # :range for range spec
                                        # :checkbox for a 0/1 valued checkbox
    :checkbox_value => '1',             # value if checkbox is checked
    :checkbox_label => '',              # text behind the checkbox
    :filter_width => '97%',             # width of the filter <input>
    :range_filter_symbol => '&ndash;',  # put between the <inputs> of the range filter
    :format => false,                   # a sprintf-string or a proc to do special formatting
    :method => false,                   # if you want to get the column by a different method than its name
    :sortable => false                  # if set, sorting-stuff is added to the header cell
  }

  FINDER_INJECT_OPTIONS = {
    :pagination => :__pagination,
    :filters => :__filters
  }

end
