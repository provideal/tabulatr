
# These are extensions for use from ActionController instances
# In a seperate class call only for clearity
class Tabulatr

  # -------------------------------------------------------------------
  # Called if SomeActveRecordSubclass::find_for_table(params) is called
  #
  def self.find_for_active_record_table(klaz, params, opts={})
    # firstly, get the conditions from the filters
    cname = class_to_param(klaz)
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

    # Now, actually find the stuff
    found = klaz.find :all, :conditions => conditions,
      :limit => pagesize.to_i, :offset => ((page-1)*pagesize).to_i,
      :order  => order

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

    found
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
            nc[n.to_sym] = "/#{v[:like]}/"
          end
        else
          nc[n.to_sym.lte] = "#{v[:from]}" if v[:from].present?
          nc[n.to_sym.gte] = "#{v[:to]}" if v[:to].present?
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

    # Now, actually find the stuff
    found = klaz.find(:conditions => conditions).paginate(:page => page, :per_page => pagesize)

#      :order  => order

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

    found
  end

private

  def self.class_to_param(klaz)
    klaz.to_s.tableize.gsub("/","_")
  end

end
