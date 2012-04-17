require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Configurable do
  module MyPrefix
    class Configurable
      include Sprinkle::Configurable
      attr_option :baz
      attr_multioption :multi
      attr_flag :flag
    end
  end
  
  before do
    @configurable = MyPrefix::Configurable.new
    @value = Object.new
  end

  describe 'attr_option' do
    it 'should generate getters/setters' do
      @configurable.baz = @value
      @configurable.baz.should === @value
    end

    it 'should allow setting without equal sign' do
      @configurable.baz = @value
      @configurable.baz.should === @value
    end
  end

  describe 'attr_multioption' do
    it 'should store its values in an array' do
      @configurable.multi :xxx
      @configurable.multi :yyy
      @configurable.multi.should == [:xxx, :yyy]
    end

    it 'should allow setting without equal sign' do
      @configurable.baz = @value
      @configurable.baz.should === @value
    end
  end

  describe 'attr_flag' do
    it 'should generate flag type getters/setters' do
      @configurable.flag = true
      @configurable.flag?.should === true
    end

    it 'should allow setting without equal sign' do
      @configurable.flag true
      @configurable.flag?.should === true
    end

    it 'should allow setting to false' do
      @configurable.flag false
      @configurable.flag?.should === false
    end
  end
end
