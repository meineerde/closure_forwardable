require 'closure_forwardable/version'

require 'English'

# The {ClosureForwardable} module provides delegation of specified methods to a
# designated object, using the methods {#def_delegator} and {#def_delegators}.
#
# This module is intended to be used very similar to the `Forwardable` module in
# the Ruby standard library. For basic usage guidelines, see there. Generally,
# you should use the simple `Forwardable` module if possible as method calls
# will be slightly faster while providing the same functionality.
#
# Use {ClosureForwardable} if you need to forward methods to a receiver that
# is not available by the including module itself. Using {ClosureForwardable},
# you can forward methods to arbitrary objects.
module ClosureForwardable
  # A regular expression matching the current file so that we can filter
  # backtraces
  FILE_REGEXP = Regexp.new(Regexp.escape(__FILE__))

  @debug = nil
  class << self
    # If true, `__FILE__` will remain in the backtrace in the event an exception
    # is raised.
    attr_accessor :debug
  end

  # Takes a hash as its argument. The key is a symbol or an array of symbols.
  # These symbols correspond to method names. The value is the receiver to which
  # the methods will be delegated.
  #
  # @param [Hash<Symbol,String,Array<Symbol, String> => Object>] hash
  # @return [void]
  def closure_delegate(hash)
    hash.each do |methods, receiver|
      methods = [methods] unless methods.respond_to?(:each)
      methods.each do |method|
        def_closure_delegator(receiver, method)
      end
    end
  end

  # Shortcut for defining multiple delegator methods, but with no provision for
  # using a different name.
  #
  # @example
  #     # This definition
  #     def_delegators records, :size, :<<, :map
  #
  #     # is exactly the same as this:
  #     def_delegator records, :size
  #     def_delegator records, :<<
  #     def_delegator records, :map
  #
  # @param [Object] receiver the object which will be the receiver of all
  #   delegated methods calls
  # @param [Array<Symbol, String>] methods Any number of methods to delegate
  # @return [void]
  def def_closure_delegators(receiver, *methods)
    excluded_methods = ['__send__'.freeze, '__id__'.freeze]
    methods.each do |method|
      next if excluded_methods.include?(method.to_s)
      def_closure_delegator(receiver, method)
    end
  end

  # Define `method` as delegator instance method with an optional alias name
  # `ali`. Method calls to `ali` will be delegated to `receiver.method`.
  #
  # @example
  #     class MyQueue
  #       extend InheritedSettings::ClosureForwardable
  #
  #       attr_reader :internal
  #       def initialize
  #         @internal = []
  #       end
  #     end
  #
  #     external = []
  #     MyQueue.def_delegator external, :push, :<<
  #     queue = MyQueue.new
  #
  #     queue << 42
  #     external              #=> [42]
  #
  #     queue.internal << 23
  #     queue.internal        #=> [23]
  #     external              #=> [42]
  #
  # @param [Object] receiver the object which will be the receiver of all
  #   delegated methods calls
  # @param [Symbol, String] method the name of the method on the `receiver`
  # @param [Symbol, String] method_alias The method name created in the
  #   current module, by default, we use the same name as the method name on the
  #   `receiver`
  # @return [void]
  def def_closure_delegator(receiver, method, method_alias = method)
    define_method(method_alias) do |*args, &block|
      begin
        receiver.__send__(method, *args, &block)
      rescue Exception
        unless ::ClosureForwardable.debug
          $ERROR_POSITION.delete_if do |error_line|
            ::ClosureForwardable::FILE_REGEXP =~ error_line
          end
        end
        ::Kernel.raise
      end
    end
  end

  alias_method :delegate, :closure_delegate
  alias_method :def_delegators, :def_closure_delegators
  alias_method :def_delegator, :def_closure_delegator
end
