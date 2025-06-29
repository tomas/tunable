require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'basic setters' do

  before :all do
    load_main_settings!
    @model = TunableModel.create(name: "Yay, I'm settable!")
  end

  describe '#set_setting' do

    it 'stores new setting, without saving' do
      @model.set_setting(:foo, :bar, 123)
      # expect(@model.get_setting(:foo, :bar)).to eq(nil)
      # expect(@model.settings_hash[:foo]).to eq(nil)
      expect(@model.get_setting(:foo, :bar)).to eq(123)
      expect(@model.settings_hash[:foo]).to eq({ bar: 123 })
      @model.save
      @model.reload
      expect(@model.get_setting(:foo, :bar)).to eq(123)
      expect(@model.settings_hash[:foo]).to eq({ bar: 123 })
    end

  end

  describe '#remove_setting' do

    it 'stores new setting' do
      @model.set_setting(:foo, :bar, 123)
      @model.set_setting(:foo, :test, false)
      @model.save
      @model.reload
      @model.remove_setting(:foo, :bar)
      expect(@model.get_setting(:foo, :bar)).to eq(123)
      @model.save
      @model.reload
      expect(@model.settings_hash[:foo]).to eq({ test: false })
      @model.remove_setting(:foo, :test)
      @model.save
      @model.reload
      expect(@model.settings_hash[:foo]).to eq(nil)
    end

  end

end

describe 'main_setting setters' do

  before :all do
    load_main_settings!
    @model = TunableModel.create(name: "Yay, I'm settable!")
  end

  describe 'if key does not exist' do

    it 'saves new settings' do
      ActiveRecord::Base.connection.should_receive(:execute)
      @model.update_attribute(:boolean_setting, true)
      @model.reload
      # expect(@model.boolean_setting).to equal(true)
    end

  end

  describe 'if key exists' do

    describe 'and value is exactly the same' do

      before do
        @model.update_attribute(:boolean_setting, true)
      end

      it 'does not save any new settings' do
        ActiveRecord::Base.connection.should_not_receive(:execute)
        @model.update_attribute(:boolean_setting, true)
      end

    end

    describe 'and value is different but truthy' do

      before do
        @model.update_attribute(:boolean_setting, true)
      end

      it 'does not save any new settings' do
        ActiveRecord::Base.connection.should_not_receive(:execute)
        @model.update_attribute(:boolean_setting, 'on')
      end

    end

    describe 'and value is different and falsy' do

      before do
        @model.update_attribute(:boolean_setting, true)
      end

      it 'saves new setting' do
      ActiveRecord::Base.connection.should_receive(:execute).once
        @model.update_attribute(:boolean_setting, 'off')
      end
    end

  end

end
