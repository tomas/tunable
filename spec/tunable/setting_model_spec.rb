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

  describe '.import SQL quoting' do
    it 'wraps boolean true/false in single quotes, not double quotes' do
      columns = [:context, :key, :value, :settable_id, :settable_type]
      values = [
        ['test', 'bool_true', true, 1, 'TunableModel'],
        ['test', 'bool_false', false, 1, 'TunableModel'],
      ]

      sqls = []
      expect(ActiveRecord::Base.connection).to receive(:execute).twice do |sql|
        sqls << sql
      end

      Tunable::Setting.import(columns, values, method: 'REPLACE')

      sqls.each do |sql|
        expect(sql).not_to include('"true"')
        expect(sql).not_to include('"false"')
      end

      expect(sqls.any? { |s| s.include?("'true'") }).to be true
      expect(sqls.any? { |s| s.include?("'false'") }).to be true
    end
  end

end