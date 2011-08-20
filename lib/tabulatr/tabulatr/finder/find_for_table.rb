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

# These are extensions for use from ActionController instances
# In a seperate class call only for clearity
module Tabulatr::Finder

  # -------------------------------------------------------------------
  # Called if SomeActveRecordSubclass::find_for_table(params) is called
  #
  def self.find_for_table(klaz, params, o={}, &block)
    rel = klaz
    typ = if klaz.respond_to?(:descends_from_active_record?) and klaz.descends_from_active_record? then :ar
      elsif klaz.include?(Mongoid::Document) then :mongoid 
      else raise("Don't know how to deal with class '#{klaz}'")
    end
      
    # on the first run, get the correct like db-operator, can still be ovrrridden
    unless typ != :ar || Tabulatr::SQL_OPTIONS[:like]
      case ActiveRecord::Base.connection.class.to_s
        when "ActiveRecord::ConnectionAdapters::MysqlAdapter" then Tabulatr.sql_options(:like => 'LIKE')
        when "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter" then Tabulatr.sql_options(:like => 'ILIKE')
        when "ActiveRecord::ConnectionAdapters::SQLiteAdapter" then Tabulatr.sql_options(:like => 'LIKE')
        when "ActiveRecord::ConnectionAdapters::SQLite3Adapter" then Tabulatr.sql_options(:like => 'LIKE')
        else 
          warn("Tabulatr Warning: Don't know which LIKE operator to use for the ConnectionAdapter '#{ActiveRecord::Base.connection.class}'.\n" +
            "Please specify by `Tabulatr.sql_options(:like => '<likeoperator>')`")
          Tabulatr.sql_options(:like => 'LIKE')
      end
    end

    form_options = Tabulatr.table_form_options
    opts = Tabulatr.finder_options.merge(o)
    params ||= {} # just to be sure
    cname           = class_to_param(klaz)
    pagination_name = "#{cname}#{form_options[:pagination_postfix]}"
    sort_name       = "#{cname}#{form_options[:sort_postfix]}"
    filter_name     = "#{cname}#{form_options[:filter_postfix]}"
    batch_name      = "#{cname}#{form_options[:batch_postfix]}"
    check_name      = "#{cname}#{form_options[:checked_postfix]}"

    # before we do anything else, we find whether there's something to do for batch actions
    checked_param = ActiveSupport::HashWithIndifferentAccess.new({:checked_ids => '', :current_page => []}).
      merge(params[check_name] || {})
    id = (typ==:ar ? klaz.primary_key.to_sym : :id)
    id_type = (typ==:ar ? klaz.columns_hash[id.to_s].type : :string)
    checked_ids = uncompress_id_list(checked_param[:checked_ids])
    new_ids = checked_param[:current_page]
    new_ids.map!(&:to_i) if id_type==:integer
    selected_ids = checked_ids + new_ids
    batch_param = params[batch_name]
    if batch_param.present? and block_given?
      batch_param = batch_param.keys.first.to_sym if batch_param.is_a?(Hash)
      yield(Invoker.new(batch_param, selected_ids))
    end
    
    # then, we obey any "select" buttons if pushed
    precon = rel
    precon = precon.where(opts[:precondition]) if opts[:precondition].present?
    if checked_param[:select_all]
      selected_ids = (typ==:ar ? precon.select(:id) : precon.only(:id) ).to_a.map { |r| r.send(id) }
    elsif checked_param[:select_none]
      selected_ids = []
    elsif checked_param[:select_visible]
      visible_ids = uncompress_id_list(checked_param[:visible])
      selected_ids = (selected_ids + visible_ids).sort.uniq
    elsif checked_param[:unselect_visible]
      visible_ids = uncompress_id_list(checked_param[:visible])
      selected_ids = (selected_ids - visible_ids).sort.uniq
    end
    
    # at this point, we've retrieved the filter settings, the sorting setting, the pagination settings and 
    # the selected_ids.
    filter_param = (params[filter_name] || {})
    sortparam = params[sort_name]
    pops = params[pagination_name] || {}

    # store the state if appropriate
    if opts[:stateful]
      session = opts[:stateful]
      sname = "#{cname}#{form_options[:state_session_postfix]}"
      raise "give the session as the :stateful parameter in find_for_table, not a '#{session.class}'" \
        unless session.is_a?(Rails::version.to_f >= 3.1 ? ActiveSupport::HashWithIndifferentAccess : ActionDispatch::Session::AbstractStore::SessionHash)
      session[sname] ||= {}
      
      if params["#{cname}#{form_options[:reset_state_postfix]}"]
        # clicked reset button, reset all and clear session
        selected_ids = []
        filter_param = {}
        sortparam = nil
        pops = {}
        session.delete sname
      elsif !pops.present? && !selected_ids.present? && !sortparam.present? && !filter_param.present?
        # we're supposed to retrieve the state from the session if applicable
        state = session[sname]
        selected_ids = state[:selected_ids] || []
        filter_param = state[:filter_param] || {}
        sortparam    = state[:sortparam]
        pops         = state[:paging_param] || {}
      else
        # store the current settings into the session to be stateful ;)
        session[sname][:selected_ids] = selected_ids
        session[sname][:filter_param] = filter_param
        session[sname][:sortparam]    = sortparam
        session[sname][:paging_param] = pops
      end
    end

    # firstly, get the conditions from the filters
    includes = []
    rel = rel.where(opts[:precondition]) if opts[:precondition]
    conditions = filter_param.each do |t|
      n, v = t
      next unless v.present?
      # FIXME n = name_escaping(n)
      if (n != form_options[:associations_filter])
        table_name = (typ==:ar ? klaz.table_name : klaz.to_s.tableize.gsub('/','_'))
        rel = condition_from(rel, typ, "#{table_name}.#{n}", v)
      else
        v.each do |t|
          n,v = t
          assoc, att = n.split(".").map(&:to_sym)
          r = klaz.reflect_on_association(assoc)
          includes << assoc
          table_name = (typ==:ar ? klaz.table_name : klaz.to_s.tableize)
          nn = "#{table_name}.#{att}"
          rel = condition_from(rel, typ, nn, v)
        end
      end
    end

    # more button handling
    if checked_param[:select_filtered]
      all = rel.all
      selected_ids = (selected_ids + all.map { |r| i=r.send(id); i.is_a?(Fixnum) ? i : i.to_s }).sort.uniq
    elsif checked_param[:unselect_filtered]
      all = rel.dup.all
      selected_ids = (selected_ids - all.map { |r| i=r.send(id); i.is_a?(Fixnum) ? i : i.to_s }).sort.uniq
    end

    # secondly, find the order_by stuff
    if sortparam
      if sortparam[:_resort]
        order_by = sortparam[:_resort].first.first
        order_direction = sortparam[:_resort].first.last.first.first
      else
        order_by = sortparam.first.first
        order_direction = sortparam.first.last.first.first
      end
      raise "SECURITY violation, sort field name is '#{n}'" unless /^[\w]+$/.match order_direction
      raise "SECURITY violation, sort field name is '#{n}'" unless /^[\d\w]+$/.match order_by
    else
      if opts[:default_order]
        l = opts[:default_order].split(" ")
        raise(":default_order parameter should be of the form 'id asc' or 'name desc'.") \
          if l.length == 0 or l.length > 2
        order_by = l[0]
        order_direction = l[1] || 'asc'
      else
        order = order_by = order_direction = nil
      end
    end
    order = (typ==:ar ? "#{order_by} #{order_direction}" : [order_by.to_s, order_direction.to_s]) if order_by

    # thirdly, get the pagination data
    paginate_options = Tabulatr.paginate_options.merge(opts).merge(pops)
    pagesize = (pops[:pagesize] || opts[:default_pagesize] || paginate_options[:pagesize]).to_f
    page = paginate_options[:page].to_i
    page += 1 if paginate_options[:page_right]
    page -= 1 if paginate_options[:page_left]
    c = rel.count
    # Group statments return a hash
    c = c.count unless c.class == Fixnum
    pages = (c/pagesize).ceil
    page = [1, [page, pages].min].max
    total = klaz
    total = total.where(opts[:precondition]) if opts[:precondition]
    # here too
    total = total.count
    total = total.count unless total.class == Fixnum
    
    # Now, actually find the stuff
    found = rel.limit(pagesize.to_i).offset(((page-1)*pagesize).to_i
     ).order(order).to_a #, :include => includes

    # finally, inject methods to retrieve the current 'settings'
    found.define_singleton_method(:__filters) do filter_param end
    found.define_singleton_method(:__classinfo) do [cname, id, id_type] end
    found.define_singleton_method(:__pagination) do
      { :page => page, :pagesize => pagesize, :count => c, :pages => pages,
        :pagesizes => paginate_options[:pagesizes],
        :total => total }
    end
    found.define_singleton_method(:__sorting) do
      order ? { :by => order_by, :direction => order_direction } : nil
    end
    visible_ids = (found.map { |r| r.send(id) })
    checked_ids = compress_id_list(selected_ids - visible_ids)
    visible_ids = compress_id_list(visible_ids)
    found.define_singleton_method(:__checked) do
      { :selected => selected_ids,
        :checked_ids => checked_ids,
        :visible => visible_ids
      }
    end
    found.define_singleton_method(:__stateful) do
      (opts[:stateful] ? true : false)
    end
    found.define_singleton_method(:__store_data) do
      opts[:store_data] || {}
    end

    found
  end

end
