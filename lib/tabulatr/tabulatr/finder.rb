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
module Tabulatr::Finder

  require File.join(File.dirname(__FILE__), 'finder', 'find_for_table')

  # compress the list of ids as good as I could imagine ;)
  # uses fancy base twisting
  def self.compress_id_list(list)
    if list.length == 0
      ""
    elsif list.first.is_a?(Fixnum)
      IdStuffer.stuff(list)
    else
      "GzB" + Base64.encode64s(
        Zlib::Deflate.deflate(
          list.join(Tabulatr.table_form_options[:checked_separator])))
    end
  end

  # inverse of compress_id_list
  def self.uncompress_id_list(str)
    if !str.present?
      []
    elsif str.starts_with?("GzB")
      Zlib::Inflate.inflate(Base64.decode64(str[3..-1])).split(
      Tabulatr.table_form_options[:checked_separator])
    else
      IdStuffer.unstuff(str)
    end
  end

  class Invoker
    def initialize(batch_action, ids)
      @batch_action = batch_action.to_sym
      @ids = ids
    end

    def method_missing(name, *args, &block)
      if @batch_action == name
        yield(@ids)
      end
    end
  end

private

  def self.class_to_param(klaz)
    klaz.to_s.downcase.gsub("/","_")
  end

  def self.condition_from(rel, typ, n, v)
    raise "SECURITY violation, field name is '#{n}'" unless /^[\d\w]+(\.[\d\w]+)?$/.match n
    @like ||= Tabulatr.sql_options[:like]
    if v.is_a?(String)
      if v.present?
        if typ == :ar
          rel = rel.where(n => v) 
        elsif typ == :mongoid 
          nn = n.split('.').last
          rel = rel.where(nn => v) 
        else raise "Unknown db type '#{typ}'"
        end
      end
    elsif v.is_a?(Hash)
      if v[:like]
        if v[:like].present?
          if typ==:ar
            rel = rel.where("#{n} #{@like} ?", "%#{v[:like]}%")
          elsif typ==:mongoid
            nn = n.split('.').last
            rel = rel.where(nn => Regexp.new(v[:like]))
          else
            raise "Unknown db type '#{typ}'"
          end
        end
      else
        if typ==:ar
          rel = rel.where("#{n} >= ?", "#{v[:from]}") if v[:from].present?
          rel = rel.where("#{n} <= ?", "#{v[:to]}") if v[:to].present?
        elsif typ==:mongoid
          nn = n.split('.').last.to_sym
          rel = rel.where(nn.gte => v[:from]) if v[:from].present?
          rel = rel.where(nn.lte => v[:to]) if v[:to].present?
        else
          raise "Unknown db type '#{typ}'"
        end
      end
    else
      raise "Wrong filter type: #{v.class}"
    end
    rel
  end
end
