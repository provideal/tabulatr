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

#--
# Monkey Patching...
#--

require 'tabulatr/tabulatr'

class ActionView::Base
  # render the table in a view
  def table_for(records, opts={}, &block)
    tabulatr = Tabulatr.new(records, self, opts)
    tabulatr.build_table(&block)# von concat , block.binding
  end
end

class ActionController::Base
  # get the correct settings from the current params hash
  def get_table_options(opts={})
    val = Tabulatr.get_table_options(opts, params)
    @page = val[:paginate][:page]
    @pagesize = val[:paginate][:pagesize]
    @filter = val[:filter]
    @sort_by = val[:sort_by]
  end
end

if Object.const_defined? "ActiveRecord"
  class ActiveRecord::Base
    def self.find_for_table(params, opts={}, &block)
      Tabulatr.find_for_active_record_table(self, params, opts, &block)
    end
  end
end

if Object.const_defined? "Mongoid"
  module Mongoid::Document
    module ClassMethods
      def find_for_table(params, opts={}, &block)
        Tabulatr.find_for_mongoid_table(self, params, opts, &block)
      end
    end
  end
end

module MarkAsLocalizable
  def l
    @should_localize = true
    self
  end

  def should_localize?
    @should_localize == true
  end
end

class String
  include MarkAsLocalizable
end

class Symbol
  include MarkAsLocalizable
end