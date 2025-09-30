require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tunable::Setting do

  before :all do
    load_main_settings!
    @model = TunableModel.create(name: "Yay, I'm settable!")
  end

  describe '#value=' do

    it 'normalizes correctly' do
      setting = @model.settings.new(context: 'test', key: 'foo', value: 'true')
      expect(setting.value).to eq('true')
      expect(setting[:value]).to eq('true')

      setting.value = true
      expect(setting.value).to eq('true')
      expect(setting[:value]).to eq('true')

      setting.value = 'false'
      expect(setting.value).to eq('false')
      expect(setting[:value]).to eq('false')

      setting.value = false
      expect(setting.value).to eq('false')
      expect(setting[:value]).to eq('false')

      setting.value = '1'
      expect(setting.value).to eq('1')
      expect(setting[:value]).to eq('1')

      setting.value = 1
      expect(setting.value).to eq('1')
      expect(setting[:value]).to eq('1')

      setting.value = '0'
      expect(setting.value).to eq('0')
      expect(setting[:value]).to eq('0')

      setting.value = 0
      expect(setting.value).to eq('0')
      expect(setting[:value]).to eq('0')
    end

  end

end