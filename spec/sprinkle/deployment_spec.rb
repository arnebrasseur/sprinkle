require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Deployment do
  include Sprinkle::Deployment
  
  def create_deployment(&block)
    deployment do
      delivery :capistrano, &block
      
      source do
        prefix '/usr/local'
      end
    end
  end

  describe 'when created' do

    it 'should be invalid without a block descriptor' do
      lambda { deployment }.should raise_error
    end

    it 'should be invalid without a delivery method' do
      lambda { Sprinkle::Script.current.deployment = deployment do; end }.should raise_error
    end

    it 'should optionally accept installer defaults' do 
      Sprinkle::Script.current.deployment = create_deployment
      Sprinkle::Script.current.deployment.should respond_to(:source)
    end
    
    it 'should provide installer defaults as a proc when requested' do 
      Sprinkle::Script.current.deployment = create_deployment
      Sprinkle::Script.current.deployment.defaults[:source].class.should == Proc
    end
    
  end 
  
  describe 'delivery specification' do
    
    before do
      @actor = mock(Sprinkle::Actors::Capistrano)
      Sprinkle::Actors::Capistrano.stub!(:new).and_return(@actor)
    end

    it 'should automatically instantiate the delivery type' do 
      Sprinkle::Script.current.deployment = create_deployment
      Sprinkle::Script.current.deployment.style.should == @actor
    end

    it 'should optionally accept a block to pass to the actor' do
      lambda { Sprinkle::Script.current.deployment = create_deployment }.should_not raise_error
    end

    describe 'with a block' do

      it 'should pass the block to the actor for configuration' do
        Sprinkle::Script.current.deployment = create_deployment do; recipes 'deploy'; end
      end

    end
  end
  
  describe 'when processing policies' do 
    
    before do 
      @policy = mock(Policy, :process => true)
      POLICIES = [ @policy ]
      Sprinkle::Script.current.deployment = create_deployment
    end
    
    it 'should apply all policies, passing itself as the deployment context' do
      @policy.should_receive(:process).with(Sprinkle::Script.current.deployment).and_return
    end
    
    after do
      Sprinkle::Script.current.deployment.process
    end
  end

end
