class Tabulatr::Adapter
  def initialize(klaz)
    @base = klaz
    @relation = klaz
  end

  delegate :all, :dup, :count, :limit, :to => :@relation

  def to_sql
    @relation.to_sql if @relation.respond_to? :to_sql
  end

  def class_to_param
    @relation.to_s.downcase.gsub("/","_")
  end

  def preconditions_scope(opts)
    opts[:precondition].present? ? @base.where(opts[:precondition]) : @base
  end

  def order(sortparam, default, maps={})
    order_by, order_direction = sort_params(sortparam, default)
    order_by ? { :by => maps[order_by] || order_by, :direction => order_direction } : nil
  end

  def sort_params(sortparam, default)
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
      if default
        l = default.split(" ")
        raise(":default_order parameter should be of the form 'id asc' or 'name desc'.") if l.length == 0 or l.length > 2

        order_by = l[0]
        order_direction = l[1] || 'asc'
      else
        order_by = order_direction = nil
      end
    end

    return order_by, order_direction
  end
end

Dir[File.join(File.dirname(__FILE__), "adapter", "*.rb")].each do |file|
  require file
end
