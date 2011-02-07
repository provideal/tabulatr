require "active_support/hash_with_indifferent_access"

class Tabulatr #::Settings

  # these settings are considered constant for the whole application, can not be overridden
  # on a per-table basis
  TABLE_DESIGN_OPTIONS = ActiveSupport::HashWithIndifferentAccess.new({
    :sortable => 'sortable',                    # class for the header of a sortable column
    :sorting_asc => 'sorting-asc',              # class for the currently asc sorting column
    :sorting_desc => 'sorting-desc',            # class for the currently desc sorting column
    :page_left_id => 'page-left',               # id for the page left <a>
    :page_right_id => 'page-right',             # id for the page right <a>
    :page_no_id => 'page-no',                   # id for the page no <input>
    :control_div_id => 'table-controls',        # id of the div containing the paging and batch action controls
    :paginator_div_id => 'paginator',           # id of the div containing the paging controls
    :batch_actions_div_id => 'batch-actions',   # id of the dic containing the batch action controls
    :submit_class => 'submit-table',            # class of submit button
    :submit_label => 'Apply',                   # Text on the submit button
    :pager_left_button => '/images/tabulatr/pager_arrow_left.gif',
    :pager_left_button_inactive => '/images/tabulatr/pager_arrow_left_off.gif',
    :pager_right_button => '/images/tabulatr/pager_arrow_right.gif',
    :pager_right_button_inactive => '/images/tabulatr/pager_arrow_right_off.gif',
    :sort_up_button => '/images/tabulatr/sort_arrow_up.gif',
    :sort_up_button_inactive => '/images/tabulatr/sort_arrow_up_off.gif',
    :sort_down_button => '/images/tabulatr/sort_arrow_down.gif',
    :sort_down_button_inactive => '/images/tabulatr/sort_arrow_down_off.gif',
    :select_all_label => 'Select All',
    :select_none_label => 'Select None',
    :select_visible_label => 'Select visible',
    :unselect_visible_label => 'Unselect visible',
    :select_filtered_label => 'Select filtered',
    :unselect_filtered_label => 'Unselect filtered',
    :info_text => "Showing %1$d, total %2$d, selected %3$d, matching %4$d"
  })

  TABLE_FORM_OPTIONS = ActiveSupport::HashWithIndifferentAccess.new({
    :batch_action_name => 'batch_action',       # name of the batch action param
    :sort_by_key => 'sort_by_key',              # name of key which to search, format is 'id asc'
    :pagination_postfix => '_pagination',       # name of the param w/ the pagination infos
    :filter_postfix => '_filter',               # postfix for name of the filter in the params hash: xxx_filter
    :sort_postfix => '_sort',                   # postfix for name of the filter in the params hash: xxx_filter
    :checked_postfix => '_checked',             # postfix for name of the checked in the params hash: xxx_filter
    :method => 'post',                          # http method for that form if applicable
    :batch_postfix => '_batch',                 # postfix for name of the batch action select
    :checked_separator => ','                   # symbol to separate the checked ids
  })

  PAGINATE_OPTIONS = ActiveSupport::HashWithIndifferentAccess.new({
    :page => 1,
    :pagesize => 10,
    :pagesizes => [10, 20, 50]
  })

  # Hash keeping the defaults for the table options, may be overriden in the
  # table_for call
  TABLE_OPTIONS = ActiveSupport::HashWithIndifferentAccess.new({
    :make_form => true,          # whether or not to wrap the whole table (incl. controls) in a form
    :table_html => false,        # a hash with html attributes for the table
    :row_html => false,          # a hash with html attributes for the normal trs
    :header_html => false,       # a hash with html attributes for the header trs
    :filter_html => false,       # a hash with html attributes for the filter trs
    :filter => true,             # false for no filter row at all
    :paginate => false,          # true to show paginator
    :sortable => true,           # true to allow sorting (can be specified for every sortable column)
    :check_controls => true,     # true to render "select all", "select none" and the like
    :action => nil,              # target action of the wrapping form if applicable
    :batch_actions => false,     # name => value hash of batch action stuff
    :join_symbol => ', '         # symbol used to join the elements of 'many' associations
  })

  # Hash keeping the defaults for the column options
  COLUMN_OPTIONS = ActiveSupport::HashWithIndifferentAccess.new({
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
    :link => false,                     # proc or symbol to make the content a link
    :sortable => true                   # if set, sorting-stuff is added to the header cell
  })

  FINDER_INJECT_OPTIONS = ActiveSupport::HashWithIndifferentAccess.new({
    :pagination => :__pagination,
    :filters => :__filters,
    :classname => :__classname,
    :sorting => :__sorting,
    :checked => :__checked
  })

end
