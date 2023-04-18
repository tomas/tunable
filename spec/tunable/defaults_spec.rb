require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe 'defaults' do

  TEST_SETTINGS = {
    :true_setting    => { :default => true, :strict => true },
    :false_setting   => { :default => false, :strict => true },
    :numeric_setting => { :default => 10, :strict => true },
    :string_setting  => { :default => 'hola', :strict => true }
  }

  describe 'without defaults' do

    before do
      TunableModel.main_settings(*TEST_SETTINGS.keys)
    end

    describe 'getting' do

      describe 'and value is not set' do

        before do
          @foo = TunableModel.new
        end

        describe 'settings_hash' do
          TEST_SETTINGS.each do |key, opts|
            it "#{key} is not present" do
              @foo.settings_hash[key].should be_nil
            end
          end
        end

        describe 'get_setting' do
          TEST_SETTINGS.each do |key, opts|
            it "#{key} is not present" do
              @foo.get_main_setting(key).should be_nil
            end
          end
        end

      end

    end

  end

  describe 'with defaults' do

    before do
      TunableModel.main_settings(TEST_SETTINGS)
    end

    describe 'getting' do

      describe 'and value is not set' do

        before do
          @foo = TunableModel.new
        end

        describe 'settings_hash' do

          TEST_SETTINGS.each do |key, opts|
            it "#{key} is not present" do
              @foo.settings_hash[key].should be_nil
            end
          end

        end

        describe 'get_setting' do

          TEST_SETTINGS.each do |key, opts|
            it "#{key} is not present" do
              @foo.get_main_setting(key).should == opts[:default]
            end
          end

        end

      end

      describe 'and value is set' do

        before do
          @new_settings = {
            :true_setting    => false,
            :false_setting   => true,
            :numeric_setting => 5,
            :string_setting  => 'chao'
          }

          @foo = TunableModel.new
          @foo.update(@new_settings)
        end

        describe 'settings_hash' do

          TEST_SETTINGS.each do |key, val|
            it "#{key} equals new val" do
              @foo.main_settings[key].should === @new_settings[key]
            end
          end

        end

        describe 'get_setting' do

          TEST_SETTINGS.each do |key, val|
            it "#{key} equals new val" do
              @foo.get_main_setting(key).should === @new_settings[key]
            end
          end
        end

      end

    end

  end

  describe 'settings with proc as default value' do

    before do
      TunableModel.main_settings true_setting: {
        :default => lambda{ |o| o.name == "a" }
      }
    end

    it "setting will respond to lambda condition" do
      model = TunableModel.create(name: "a")
      expect(model.true_setting).to be(true)
    end

    it "setting will respond to lambda condition" do
      model = TunableModel.create(name: "b")
      expect(model.true_setting).to be(false)
    end
  end

end
