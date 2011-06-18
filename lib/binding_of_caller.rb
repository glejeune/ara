# Copyright (c) 2011 James M. Lawrence. All rights reserved.
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'continuation'

module BindingOfCaller
VERSION = "0.1.3"

module_function

def binding_of_caller
   cont = nil
   event_count = 0

   tracer = lambda do |event, _, _, _, binding, _|
      event_count += 1
      if event_count == 4
         Thread.current.set_trace_func(nil)
         case event
            when "return", "line", "end"
               cont.call(nil, binding)
            else
               error_msg = "\n" <<
               "Invalid use of binding_of_caller. One of the following:\n" <<
               "  (1) statements exist after the binding_of_caller block;\n" <<
               "  (2) the method using binding_of_caller appears inside\n" <<
               "      a method call;\n" <<
               "  (3) the method using binding_of_caller is called from the\n" << 
               "      last line of a block or global scope.\n" <<
               "See the documentation for binding_of_caller.\n"
               cont.call(nil, nil, lambda { raise(ScriptError, error_msg) })
            end
         end
      end

      cont, result, error = callcc { |cc| cc }
      if cont
         Thread.current.set_trace_func(tracer)
      elsif result
         yield result
      else
         error.call 
      end
   end
end
