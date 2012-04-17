module Sprinkle
  module Actors
    # Base class for Actors
    class Actor
      include Sprinkle::Configurable
      alias :deployment :parent
      attr_flag :verbose
      
      def initialize(deployment)
        @parent = deployment
      end
    end
  end
end
