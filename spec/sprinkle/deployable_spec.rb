require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Deployable do
  module MyPrefix
    class Deployable
      include Sprinkle::Deployable
    end
  end
  
  before do
    @configurable = MyPrefix::Deployable.new
    @default = Proc.new { }
    @defaults = { :deployable => @default }
    @deployment = Object.new
    @deployment.stub!(:defaults).and_return(@defaults)
    @deployment.stub!(:style)
  end

  it 'should be configurable via external defaults' do
    @configurable.should respond_to(:defaults)
  end

  it 'should select the defaults for the particular concrete installer class' do
    @deployment.should_receive(:defaults).and_return(@defaults)
    @defaults.should_receive(:[]).with(:deployable).and_return(@default)
  end

  it 'should configure the installer delivery mechansim' do
    @configurable.should_receive(:instance_eval)
  end
  
  it 'should allow the delivery instance variable to be accessed' do
    @configurable.delivery = "string"
    @configurable.instance_variable_get(:@delivery).should eql("string")
  end

  after do
    @configurable.defaults(@deployment)
  end
end
