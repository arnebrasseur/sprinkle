module Sprinkle
  # = Programmatically Run Sprinkle
  #
  # Sprinkle::Script gives you a way to programatically run a given
  # sprinkle script.
  #
  # script = Sprinkle::Script.new
  # script.load_script IO.read('recipe.rb'), 'recipe.rb'
  # script.load_block do
  #   deploy :capistrano do
  #     #...
  #   end
  # end
  # script.sprinkle
  class Script
    include Sprinkle::Configurable

    cattr_accessor :instance

    DEFAULT_OPTIONS = {
      :testing => false, 
      :verbose => false, 
      :force => false, 
      :use_sudo => true
    }
    
    class << self
      # Run a given sprinkle script. This method is <b>blocking</b> so
      # it will not return until the sprinkling is complete or fails.
      def sprinkle(script, filename = '__SCRIPT__', options = {})
        powder = new(options)
        powder.load_script script, filename
        powder.sprinkle
      end
    end

    attr_reader :packages, :policies
    attr_accessor :deployment
    attr_flag :testing, :verbose, :force, :use_sudo

    def initialize(options = {})
      @options = options.reverse_merge(DEFAULT_OPTIONS)
      @packages = {}
      @policies = []
      @deployment = nil
    end

    # Load a script containing sprinkle configuration
    def load_script(script, filename = '__SCRIPT__')
      self.instance_eval script, filename
    end

    # Load a block containing sprinkle configuration
    def load_block(&blk)
      self.instance_eval &blk
    end

    # Execute the defined policies through the specified deployment actor
    def sprinkle
      @deployment.process if @deployment
    end

    def option(name)
      @options[name]
    end

    ######## DSL ##########

    def package(name, metadata = {}, &block)
      package = Package::Package.new(self, name, metadata, &block)
      @packages[name] = package

      if package.provides
        (@packages[package.provides] ||= []) << package
      end

      package
    end

    # Defines a single policy. Currently the only option, which is also
    # required, is :roles, which defines which servers a policy is
    # used on.
    def policy(name, options = {}, &block)
      p = Policy::Policy.new(self, name, options, &block)
      @policies << p
      p
    end

    def deployment(&block)
      @deployment = Deployment::Deployment.new(self, &block)
    end

  end
end
