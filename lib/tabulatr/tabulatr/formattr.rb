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

module Tabulatr::Formattr
  ALLOWED_METHODS = [:euro, :dollar, :percent, :lamp]
  #include ActionView::TagHelpers
  
  def self.format(nam, val)
    nam = nam.to_sym
    if ALLOWED_METHODS.member?(nam)
      self.send nam, val
    else
      "[Requested unautorized format '#{nam}' for '#{val}'.]" 
    end
  end
  
  def self.euro(x)
    ("%.2f&thinsp;&euro;" % x).gsub(".", ",")
  end
  
  def self.dollar(x)
    "$&thinsp;%.2f" % x
  end
  
  def self.percent(x)
    ("%.2f&thinspace;%%" % 100.0*x).gsub(".", ",")
  end
  
  def self.lamp(x, mapping)
    s = mapping[x].to_s
    return "?" unless %w{g y r n}.member?(s)
    image_tag("tabulatr/#{s}state.gif").html_safe
  end
  
end