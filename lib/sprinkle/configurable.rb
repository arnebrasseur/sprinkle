module Sprinkle

  # Everything that can be configured through the DSL (packages, policies, deployment, installers, verifiers)
  # uses this unified way of accessing options. They are stored in the @options Hash, but getters/setters can
  # be generated with attr_option, which works just like attr_accessor.
  #
  # When @parent is set, then options that aren't set in this instance will be lookup up in the parent.
  # E.g. the Sprinkle::Script defaults to having sudo on, but a certain package may want to have sudo off.
  # An installer in that package may then again choose to have sudo on.
  module Configurable 
    extend ActiveSupport::Concern
    attr_accessor :options, :parent

    module ClassMethods
      protected

      # Generate getters/setters that behave like attr_accessor, except
      # they're backed by the @options hash rather than instance variables.
      #
      # One quirk is that the getters behaves as setters when arguments are given.
      # So 
      #    version = '1.1.0'
      # and
      #    version '1.1.0'
      # do the same thing.
      def attr_option(*attrs)
        attrs.each do |sym|
          sym=sym.to_sym

          define_method sym do |*args|
            if args.empty?
              fetch_option sym
            else
              @options ||= {}
              @options[sym] = args.first
            end
          end

          define_method :"#{sym}=" do |*args|
            @options ||= {}
            @options[sym] = args.first
          end

        end
      end

      # For options that can ben specified multiple times,
      # they will be stored in an array.
      def attr_multioption(*attrs)
        attrs.each do |sym|
          sym=sym.to_sym

          define_method sym do |*args|
            if args.empty?
              fetch_option sym
            else
              @options ||= {}
              (@options[sym] ||= []) << args.first
            end
          end

        end
      end

      # For boolean options. e.g.
      # class:
      #   attr_flag :use_sudo'
      #
      # self.use_sudo true
      # self.use_sudo # Same, default sets to true
      # self.use_sudo? #=> true
      def attr_flag(*attrs)
        attrs.each do |sym|
          sym=sym.to_sym

          define_method sym do |*args|
            @options ||= {}
            @options[sym] = args.empty? ? true : args.first
          end

          define_method :"#{sym}\?" do |*args|
            !! fetch_option(sym)
          end

          define_method :"#{sym}=" do |*args|
            @options ||= {}
            @options[sym] = args.first
          end
        end
      end
    end

    # Look up in @options, delegating to the @parent if the option isn't set
    def fetch_option(name)
      name = name.to_sym
      @options ||= {}

      unless @options[name].nil? 
        @options[name]
      else
        @parent.try(:fetch_option, name) 
      end 
    end
    alias :option? :fetch_option
    
    #def method_missing(name, *args)
    #  @@file ||= File.open('/tmp/xxx','a')
    #  @@file << self.class << ' :' << name << "\n"
    #  fetch_option(name)
    #end
    
  end
    
end
