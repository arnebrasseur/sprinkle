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
  #
  # It is possible to define multiple Sprinkle scripts, each with their
  # own isolated configuration. This, however, is not thread safe.
  class Script
    class << self
      # The current sprinkle script, so packages/policies/deployment can
      # register themselves
      def current
        @@current ||= new
      end

      def current=(script)
        @@current=script
      end

      # Run a given sprinkle script. This method is <b>blocking</b> so
      # it will not return until the sprinkling is complete or fails.
      def self.sprinkle(script, filename = '__SCRIPT__')
        powder = new
        powder.load_script script, filename
        powder.sprinkle
      end
    end

    attr_reader :packages
    attr_reader :policies
    attr_accessor :deployment

    def initialize
      @packages = {}
      @policies = []
      @deployment = nil
    end

    # Load a script containing sprinkle configuration
    def load_script(script, filename = '__SCRIPT__')
      Sprinkle::Script.current = self
      self.instance_eval script, filename
      Sprinkle::Script.current = nil
    end

    # Load a block containing sprinkle configuration
    def load_block(&blk)
      Sprinkle::Script.current = self
      self.instance_eval &blk
      Sprinkle::Script.current = nil
    end

    # Execute the defined policies through the specified deployment actor
    def sprinkle
      Sprinkle::Script.current = self
      @deployment.process if @deployment
      Sprinkle::Script.current = nil
    end
  end
end
