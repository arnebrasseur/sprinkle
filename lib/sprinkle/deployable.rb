module Sprinkle

  # The various installers and verifiers are deployable, this means they know about the
  # deployment delivery style being used (e.g. capistrano, ssh), and that for each
  # type of installer/verifier defaults can be configured.
  module Deployable
    attr_accessor :delivery

    # Configure this instance with the defaults that were configured for this class
    def defaults(deployment)
      defaults = deployment.defaults[self.class.name.split(/::/).last.downcase.to_sym]
      self.instance_eval(&defaults) if defaults
      @delivery = deployment.style
    end
    
    def assert_delivery
      raise 'Unknown command delivery target' unless @delivery
    end
  end

end
