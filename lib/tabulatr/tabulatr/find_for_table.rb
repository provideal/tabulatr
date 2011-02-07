
# These are extensions for use from ActionController instances
# In a seperate class call only for clearity
class Tabulatr

  # -------------------------------------------------------------------
  # Called if SomeActveRecordSubclass::find_for_table(params) is called
  #
  def self.find_for_active_record_table(klaz, params, opts={}, &block)
    cname = class_to_param(klaz)
    params ||= {}
    # before we do anything else, we find whether there's something to do for batch actions
    checked_param = ActiveSupport::HashWithIndifferentAccess.new({:checked_ids => '', :current_page => []}).
      merge(params["#{cname}#{Tabulatr::TABLE_FORM_OPTIONS[:checked_postfix]}"] || {})
    checked_ids = uncompress_id_list(checked_param[:checked_ids])
    new_ids = checked_param[:current_page]
    selected_ids = checked_ids + new_ids
    batch_param = params["#{cname}#{Tabulatr::TABLE_FORM_OPTIONS[:batch_postfix]}"]
    if batch_param.present? and block_given?
      yield(Invoker.new(batch_param, selected_ids))
    end

    # firstly, get the conditions from the filters
    filter_param = (params["#{cname}#{TABLE_FORM_OPTIONS[:filter_postfix]}"] || {})
    conditions = filter_param.inject(["(1=1) ", []]) do |c, t|
      n, v = t
      nc = c
      # FIXME n = name_escaping(n)
      raise "SECURITY violation, field name is '#{n}'" unless /^[\d\w]+$/.match n
      if v.class == String
        if v.present?
          nc = [c[0] << "AND (`#{n}` = ?) ", c[1] << v]
        end
      elsif v.is_a?(Hash)
        if v[:like]
          if v[:like].present?
            nc = [c[0] << "AND (`#{n}` LIKE ?) ", c[1] << "%#{v[:like]}%"]
          end
        else
          nc = [c[0] << "AND (`#{n}` > ?) ", c[1] << "#{v[:from]}"] if v[:from].present?
          nc = [nc[0] << "AND (`#{n}` < ?) ", nc[1] << "#{v[:to]}"] if v[:to].present?
        end
      else
        raise "Wrong filter type: #{v.class}"
      end
      nc
    end
    conditions = [conditions.first] + conditions.last

    # secondly, find the order_by stuff
    # FIXME: Implement me! PLEEEZE!
    sortparam = params["#{cname}#{Tabulatr::TABLE_FORM_OPTIONS[:sort_postfix]}"]
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
      order = "#{order_by} #{order_direction}"
    else
      order = order_by = order_direction = nil
    end

    # thirdly, get the pagination data
    paginate_options = PAGINATE_OPTIONS.merge(opts).
      merge(params["#{cname}#{TABLE_FORM_OPTIONS[:pagination_postfix]}"] || {})
    page = paginate_options[:page].to_i
    page += 1 if paginate_options[:page_right]
    page -= 1 if paginate_options[:page_left]
    pagesize = paginate_options[:pagesize].to_f
    c = klaz.count :conditions => conditions
    pages = (c/pagesize).ceil
    page = [1, [page, pages].min].max

    debugger

    # then, we obey any "select" buttons if pushed
    if checked_param[:select_all]
      all = klaz.find :all, :select => :id
      selected_ids = all.map { |r| r.id.to_s }
    elsif checked_param[:select_none]
      selected_ids = []
    elsif checked_param[:select_visible]
      visible_ids = uncompress_id_list(checked_param[:visible])
      selected_ids = (selected_ids + visible_ids).sort.uniq
    elsif checked_param[:unselect_visible]
      visible_ids = uncompress_id_list(checked_param[:visible])
      selected_ids = (selected_ids - visible_ids).sort.uniq
    elsif checked_param[:select_filtered]
      all = klaz.find :all, :conditions => conditions, :select => :id
      selected_ids = (selected_ids + all.map { |r| r.id.to_s }).sort.uniq
    elsif checked_param[:unselect_filtered]
      all = klaz.find :all, :conditions => conditions, :select => :id
      selected_ids = (selected_ids - all.map { |r| r.id.to_s }).sort.uniq
    end


    # Now, actually find the stuff
    found = klaz.find :all, :conditions => conditions,
      :limit => pagesize.to_i, :offset => ((page-1)*pagesize).to_i,
      :order  => order

    # finally, inject methods to retrieve the current 'settings'
    found.define_singleton_method(FINDER_INJECT_OPTIONS[:filters]) do filter_param end
    found.define_singleton_method(FINDER_INJECT_OPTIONS[:classname]) do cname end
    found.define_singleton_method(FINDER_INJECT_OPTIONS[:pagination]) do
      {:page => page, :pagesize => pagesize, :count => c, :pages => pages,
        :pagesizes => paginate_options[:pagesizes], :total => klaz.count }
    end
    found.define_singleton_method(FINDER_INJECT_OPTIONS[:sorting]) do
      order ? { :by => order_by, :direction => order_direction } : nil
    end
    visible_ids = (found.map { |r| r.id.to_s })
    checked_ids = compress_id_list(selected_ids - visible_ids)
    visible_ids = compress_id_list(visible_ids)
    found.define_singleton_method(FINDER_INJECT_OPTIONS[:checked]) do
      { :selected => selected_ids,
        :checked_ids => checked_ids,
        :visible => visible_ids
      }
    end

    found
  end

  # compress the list of ids as good as I could imagine ;)
  # uses fancy base twisting
  def self.compress_id_list(list)
    return "PXS" if list.length == 0
    "PXS" << (list.sort.uniq.map(&:to_i).inject([[-9,-9]]) do |l, c|
      if l.last.last+1 == c
        l.last[-1] = c
        l
      else
        l << [c,c]
      end
    end.map do |r|
      if r.first == r.last
        r.first.to_s(8)
      else
        r.first.to_s(8) << "8" << r.last.to_s(8)
      end
    end[1..-1].join("9").to_i.to_s(36))
  end

  # inverse of compress_id_list
  def self.uncompress_id_list(str)
    return [] if !str.present? or str=='0' or str=='PXS'
    raise "Corrupted id list. Or a bug ;)" unless str.start_with?("PXS")
    n = str[3..-1].to_i(36).to_s.split("9").map do |e|
      p = e.split("8")
      if p.length == 1 then p[0].to_i(8)
      elsif p.length == 2 then (p[0].to_i(8)..p[1].to_i(8)).entries
      else raise "Corrupted id list. Or a bug ;)"
      end
    end.flatten.map &:to_s
  end


  # ----------------------------------------------------------------
  # Called if SomeMongoidDocument::find_for_table(params) is called
  #
  def self.find_for_mongoid_table(klaz, params, opts={})
    # firstly, get the conditions from the filters
    cname = class_to_param(klaz)
    filter_param = (params["#{cname}#{TABLE_FORM_OPTIONS[:filter_postfix]}"] || {})
    conditions = filter_param.inject({}) do |c, t|
      n, v = t
      nc = c
      # FIXME n = name_escaping(n)
      raise "SECURITY violation, field name is '#{n}'" unless /^[\d\w]+$/.match n
      if v.class == String
        if v.present?
          nc[n.to_sym] = v
        end
      elsif v.is_a?(Hash)
        if v[:like]
          if v[:like].present?
            nc[n.to_sym] = Regexp.new("#{v[:like]}")
          end
        else
          nc[n.to_sym.gte] = "#{v[:from]}" if v[:from].present?
          nc[n.to_sym.lte] = "#{v[:to]}" if v[:to].present?
        end
      else
        raise "Wrong filter type: #{v.class}"
      end
      nc
    end

    # secondly, find the order_by stuff
    # FIXME: Implement me! PLEEEZE!
    sortparam = params["#{cname}#{Tabulatr::TABLE_FORM_OPTIONS[:sort_postfix]}"]
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
      order = [order_by, order_direction]
    else
      order = nil
    end

    # thirdly, get the pagination data
    paginate_options = PAGINATE_OPTIONS.merge(opts).
      merge(params["#{cname}#{TABLE_FORM_OPTIONS[:pagination_postfix]}"] || {})
    page = paginate_options[:page].to_i
    page += 1 if paginate_options[:page_right]
    page -= 1 if paginate_options[:page_left]
    pagesize = paginate_options[:pagesize].to_f
    c = klaz.count :conditions => conditions
    pages = (c/pagesize).ceil
    page = [1, [page, pages].min].max

    # Now, actually find the stuff
    found = klaz.find(:conditions => conditions)
    found = found.order_by([order]) if order
    found = found.paginate(:page => page, :per_page => pagesize)

    # finally, inject methods to retrieve the current 'settings'
    found.define_singleton_method(FINDER_INJECT_OPTIONS[:filters]) do filter_param end
    found.define_singleton_method(FINDER_INJECT_OPTIONS[:classname]) do cname end
    found.define_singleton_method(FINDER_INJECT_OPTIONS[:pagination]) do
      {:page => page, :pagesize => pagesize, :count => c, :pages => pages,
        :pagesizes => paginate_options[:pagesizes]}
    end
    found.define_singleton_method(FINDER_INJECT_OPTIONS[:sorting]) do
      order ? { :by => order_by, :direction => order_direction } : nil
    end
    checked_param = params["#{cname}#{Tabulatr::TABLE_FORM_OPTIONS[:checked_postfix]}"]
    checked_ids = checked_param[:checked].split(Tabulatr::TABLE_FORM_OPTIONS[:checked_separator])
    new_ids = checked_param[:current_page] || []
    selected_ids = checked_ids + new_ids
    ids = found.map { |r| r.id.to_s }
    checked_ids = selected_ids - ids
    found.define_singleton_method(FINDER_INJECT_OPTIONS[:checked]) do
      { :selected => selected_ids,
        :checked_ids => checked_ids.join(Tabulatr::TABLE_FORM_OPTIONS[:checked_separator]) }
    end
    found
  end

  class Invoker
    def initialize(batch_action, ids)
      @batch_action = batch_action.to_sym
      @ids = ids
    end

    def method_missing(name, *args, &block)
      if @batch_action == name
        yield(@ids, args)
      end
    end
  end

private

  def self.class_to_param(klaz)
    klaz.to_s.downcase.gsub("/","_")
  end

end
