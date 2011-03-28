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

require 'whiny_hash'

class Tabulatr

  # Hash keeping the defaults for the table options, may be overriden in the
  # table_for call
  TABLE_OPTIONS = WhinyHash.new({ # WhinyHash.new({
    :remote => false,                               # add data-remote="true" to form

    :form_class => 'tabulatr_form',                 # class of the overall form
    :table_class => 'tabulatr_table',               # class for the actual data table
    :sortable_class => 'sortable',                  # class for the header of a sortable column
    :sorting_asc_class => 'sorting-asc',            # class for the currently asc sorting column
    :sorting_desc_class => 'sorting-desc',          # class for the currently desc sorting column
    :page_left_class => 'page-left',                # class for the page left button
    :page_right_class => 'page-right',              # class for the page right button
    :page_no_class => 'page-no',                    # class for the page no <input>
    :control_div_class_before => 'table-controls',  # class of the upper div containing the paging and batch action controls
    :control_div_class_after => 'table-controls',   # class of the lower div containing the paging and batch action controls
    :paginator_div_class => 'paginator',            # class of the div containing the paging controls
    :batch_actions_div_class => 'batch-actions',    # class of the div containing the batch action controls
    :select_controls_div_class => 'check-controls',  # class of the div containing the check controls
    :submit_class => 'submit-table',                # class of submit button
    :pagesize_select_class => 'pagesize_select',    # class of the pagesize select element
    :select_all_class => 'select-btn',              # class of the select all button
    :select_none_class => 'select-btn',             # class of the select none button
    :select_visible_class => 'select-btn',          # class of the select visible button
    :unselect_visible_class => 'select-btn',        # class of the unselect visible button
    :select_filtered_class => 'select-btn',         # class of the select filtered button
    :unselect_filtered_class => 'select-btn',       # class of the unselect filteredbutton
    :info_text_class => 'info-text',                # class of the info text div

    :batch_actions_label => 'Batch Actions: ',      # Text to show in front of the batch action select
    :batch_actions_type => :select,                 # :select or :button depending on the kind of input you want
    :batch_actions_class => 'batch-action-inputs',  # class to apply on the batch action input elements
    :submit_label => 'Apply',                       # Text on the submit button
    :select_all_label => 'Select All',              # Text on the select all button
    :select_none_label => 'Select None',            # Text on the select none button
    :select_visible_label => 'Select visible',      # Text on the select visible button
    :unselect_visible_label => 'Unselect visible',  # Text on the unselect visible button
    :select_filtered_label => 'Select filtered',    # Text on the select filtered button
    :unselect_filtered_label => 'Unselect filtered',# Text on the unselect filtered button
    :info_text => "Showing %1$d, total %2$d, selected %3$d, matching %4$d",

    # which controls to be rendered above and below the tabel and in which order
    :before_table_controls => [:submit, :paginator, :batch_actions, :select_controls, :info_text],
    :after_table_controls => [],

    # whih selecting controls to render in which order
    :select_controls => [:select_all, :select_none, :select_visible, :unselect_visible,
                      :select_filtered, :unselect_filtered],

    :image_path_prefix => '/images/tabulatr/',
    :pager_left_button => 'pager_arrow_left.gif',
    :pager_left_button_inactive => 'pager_arrow_left_off.gif',
    :pager_right_button => 'pager_arrow_right.gif',
    :pager_right_button_inactive => 'pager_arrow_right_off.gif',
    :sort_up_button => 'sort_arrow_up.gif',
    :sort_up_button_inactive => 'sort_arrow_up_off.gif',
    :sort_down_button => 'sort_arrow_down.gif',
    :sort_down_button_inactive => 'sort_arrow_down_off.gif',

    :make_form => true,                            # whether or not to wrap the whole table (incl. controls) in a form
    :table_html => false,                          # a hash with html attributes for the table
    :row_html => false,                            # a hash with html attributes for the normal trs
    :header_html => false,                         # a hash with html attributes for the header trs
    :filter_html => false,                         # a hash with html attributes for the filter trs
    :filter => true,                               # false for no filter row at all
    :paginate => true,                             # true to show paginator
    :sortable => true,                             # true to allow sorting (can be specified for every sortable column)
    :selectable => true,                           # true to render "select all", "select none" and the like
    :action => nil,                                # target action of the wrapping form if applicable
    :batch_actions => false,                       # :name => value hash of batch action stuff
    :translate => false,                           # call t() for all 'labels' and stuff, possible values are true/:translate or :localize
    :row_classes => ['odd', 'even']                # class for the trs
  })

  # these settings are considered constant for the whole application, can not be overridden
  # on a per-table basis.
  # That's necessary to allow find_for_table to work properly
  TABLE_FORM_OPTIONS = WhinyHash.new({
    :batch_action_name => 'batch_action',       # name of the batch action param
    :sort_by_key => 'sort_by_key',              # name of key which to search, format is 'id asc'
    :pagination_postfix => '_pagination',       # name of the param w/ the pagination infos
    :filter_postfix => '_filter',               # postfix for name of the filter in the params :hash => xxx_filter
    :sort_postfix => '_sort',                   # postfix for name of the filter in the params :hash => xxx_filter
    :checked_postfix => '_checked',             # postfix for name of the checked in the params :hash => xxx_filter
    :associations_filter => '__association',    # name of the associations in the filter hash
    :method => 'post',                          # http method for that form if applicable
    :batch_postfix => '_batch',                 # postfix for name of the batch action select
    :state_session_postfix => '_table_state',   # postfix for the state hash in the sessions
    :reset_state_postfix => '_reset_state',     # postfix for the name of the input to reset state
    :checked_separator => ','                   # symbol to separate the checked ids
  })

  # these settings are considered constant for the whole application, can not be overridden
  # on a per-table basis.
  # That's necessary to allow find_for_table to work properly
  PAGINATE_OPTIONS = ActiveSupport::HashWithIndifferentAccess.new({
    :page => 1,
    :pagesize => 10,
    :pagesizes => [10, 20, 50]
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
    :join_symbol => ', ',               # symbol used to join the elements of 'many' associations
    :map => true,                       # whether to map the call on individual records (true) or call on the list (false)
    :sortable => true                   # if set, sorting-stuff is added to the header cell
  })

  # these settings are considered constant for the whole application, can not be overridden
  # on a per-table basis.
  # That's necessary to allow find_for_table to work properly
  FINDER_INJECT_OPTIONS = WhinyHash.new({
    :pagination => :__pagination,
    :filters => :__filters,
    :classname => :__classname,
    :sorting => :__sorting,
    :checked => :__checked,
    :store_data => :__store_data
  })

  # defaults for the find_for_table
  FINDER_OPTIONS = WhinyHash.new({
    :default_order => false,
    :default_pagesize => false,
    :precondition => false,
    :store_data => false,
    :stateful => false
  })

  # Stupid hack
  SQL_OPTIONS = WhinyHash.new({
    :like => nil
  })

  def self.finder_inject_options(n=nil)
    FINDER_INJECT_OPTIONS.merge!(n) if n
    FINDER_INJECT_OPTIONS
  end

  def self.finder_options(n=nil)
    FINDER_OPTIONS.merge!(n) if n
    FINDER_OPTIONS
  end

  def self.column_options(n=nil)
    COLUMN_OPTIONS.merge!(n) if n
    COLUMN_OPTIONS
  end

  def self.table_options(n=nil)
    TABLE_OPTIONS.merge!(n) if n
    TABLE_OPTIONS
  end

  def self.paginate_options(n=nil)
    PAGINATE_OPTIONS.merge!(n) if n
    PAGINATE_OPTIONS
  end

  def self.table_form_options(n=nil)
    TABLE_FORM_OPTIONS.merge!(n) if n
    TABLE_FORM_OPTIONS
  end

  def self.table_design_options(n=nil)
    raise("table_design_options stopped existing. Use table_options instead.")
  end
  def table_design_options(n=nil) self.class.table_design_options(n) end

  def self.sql_options(n=nil)
    SQL_OPTIONS.merge!(n) if n
    SQL_OPTIONS
  end
  def sql_options(n=nil) self.class.sql_options(n) end


end
