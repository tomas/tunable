require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
