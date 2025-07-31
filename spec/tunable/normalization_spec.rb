require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'normalization' do

  before :all do
    load_main_settings!
    @model = TunableModel.create(name: "Yay, I'm settable!")
  end

  VALUE_TYPES = {
    :main => {
      :truthy => 'true',
      :falsy  => 'false',
      :t      => 't',
      :f      => 'f',
      :foo    => 'foo'
    },
    :numbers => {
      :number_0 => '0',
      :number_1 => '1',
      :number_of_the_beast => 666
    },
    :onoffs => {
      :on  => 'on',
      :off => 'off'
    },
    :yesnoes => {
      :yes => 'yes',
      :no  => 'no',
      :y   => 'y',
      :n   => 'n',
    }
  }

  let(:sql_true) {
    ActiveRecord::Base.connection.adapter_name == 'SQLite' ? 't' : 'true'
  }

  let(:sql_false) {
    ActiveRecord::Base.connection.adapter_name == 'SQLite' ? 'f' : 'false'
  }

  describe 'before saving to DB' do

    after do
      @model.boolean_setting = nil
    end

    it 'the getter returns true for 1' do
      @model.boolean_setting = 1
      @model.boolean_setting.should === 1
    end

    it 'the getter returns false for 0' do
      @model.boolean_setting = '0' # as string
      @model.boolean_setting.should === 0
    end

  end

  describe 'when inserting to DB' do

    def get_value_from_db(context, key)
      id = @model.id
      sql = "select `value` from `settings` where `settable_id` = #{id} and `context` = '#{context}' and `key` = '#{key}';"
      res = ActiveRecord::Base.connection.execute(sql)
      # puts res.inspect
      res[0] ? res[0]['value'] : nil
    end

    describe 'creating a new setting directly' do

      before :all do
        @settings = []

        VALUE_TYPES.each do |context, values|
          values.each do |key, val|
            # puts "#{context} -> #{key} -> #{val}"
            setting = Tunable::Setting.create(:context => context, :key => key, :value => val, :settable_id => @model.id)
            @settings << setting
          end
        end
      end

      after :all do
        Tunable::Setting.delete_all
      end

      it 'keeps 1 as 1' do
        get_value_from_db(:numbers, :number_1).should == '1'
      end

      it 'keeps 0 as 0' do
        get_value_from_db(:numbers, :number_0).should == '0'
      end

      it 'keeps 666 as 666' do
        get_value_from_db(:numbers, :number_of_the_beast).should == '666'
      end

      it 'keeps foo as foo' do
        get_value_from_db(:main, :foo).should == 'foo'
      end

      it 'normalizes booleany true values to 1' do
        get_value_from_db(:main, :truthy).should == sql_true
      end

      it 'normalizes booleany false values to 0' do
        get_value_from_db(:main, :falsy).should == sql_false
      end

      it 'normalizes t (from true) to true' do
        get_value_from_db(:main, :t).should == sql_true
      end

      it 'normalizes f (from false) to 0' do
        get_value_from_db(:main, :f).should == sql_false
      end

      it 'normalizes on to 1' do
        get_value_from_db(:onoffs, :on).should == sql_true
      end

      it 'normalizes off to 0' do
        get_value_from_db(:onoffs, :off).should == sql_false
      end

      it 'normalizes y to 1' do
        get_value_from_db(:yesnoes, :y).should == sql_true
      end

      it 'normalizes n to 0' do
        get_value_from_db(:yesnoes, :n).should == sql_false
      end

      it 'normalizes yes to 1' do
        get_value_from_db(:yesnoes, :yes).should == sql_true
      end

      it 'normalizes no to 0' do
        get_value_from_db(:yesnoes, :no).should == sql_false
      end

    end

    describe 'using main settings' do

      it 'keeps 1 as 1' do
        @model.update_attribute(:number_setting, 1)
        get_value_from_db(:main, :number_setting).should == '1'
      end

      it 'keeps 0 as 0' do
        @model.update_attribute(:number_setting, '0')
        get_value_from_db(:main, :number_setting).should == '0'
      end

      it 'keeps foo as foo' do
        @model.update_attribute(:other_setting, 'foo')
        get_value_from_db(:main, :other_setting).should == 'foo'
      end

      it 'normalizes booleany true values to 1' do
        # @model.update_attribute(:boolean_setting, true)
        @model.boolean_setting = true
        @model.save
        get_value_from_db(:main, :boolean_setting).should == 'true'
      end

      it 'normalizes booleany false values to 0' do
        @model.update(boolean_setting: false)
        get_value_from_db(:main, :boolean_setting).should == 'false'
      end

      it 'normalizes on to 1' do
        @model.update_attribute(:on_off_setting, 'on')
        get_value_from_db(:main, :on_off_setting).should == 'true'
      end

      it 'normalizes off to 0' do
        @model.update_attribute(:on_off_setting, 'off')
        get_value_from_db(:main, :on_off_setting).should == 'false'
      end

      it 'normalizes on to 1' do
        @model.update_attribute(:y_n_setting, 'y')
        get_value_from_db(:main, :y_n_setting).should == 'true'
      end

      it 'normalizes off to 0' do
        @model.update_attribute(:y_n_setting, 'n')
        get_value_from_db(:main, :y_n_setting).should == 'false'
      end

    end

    describe 'using settings relationship' do

      before :all do
        @model.update(:settings => VALUE_TYPES)
      end

      after :all do
        Tunable::Setting.delete_all
      end

      it 'keeps 1 as 1' do
        get_value_from_db(:numbers, :number_1).should == '1'
      end

      it 'keeps 0 as 0' do
        get_value_from_db(:numbers, :number_0).should == '0'
      end

      it 'keeps 666 as 666' do
        get_value_from_db(:numbers, :number_of_the_beast).should == '666'
      end

      it 'keeps foo as foo' do
        get_value_from_db(:main, :foo).should == 'foo'
      end

      it 'normalizes booleany true values to 1' do
        get_value_from_db(:main, :truthy).should == 'true'
      end

      it 'normalizes booleany false values to 0' do
        get_value_from_db(:main, :falsy).should == 'false'
      end

      it 'normalizes t (from true) to 1' do
        get_value_from_db(:main, :t).should == 'true'
      end

      it 'normalizes f (from false) to 0' do
        get_value_from_db(:main, :f).should == 'false'
      end

      it 'normalizes on to 1' do
        get_value_from_db(:onoffs, :on).should == 'true'
      end

      it 'normalizes off to 0' do
        get_value_from_db(:onoffs, :off).should == 'false'
      end

      it 'normalizes y to 1' do
        get_value_from_db(:yesnoes, :y).should == 'true'
      end

      it 'normalizes n to 0' do
        get_value_from_db(:yesnoes, :n).should == 'false'
      end

      it 'normalizes yes to 1' do
        get_value_from_db(:yesnoes, :yes).should == 'true'
      end

      it 'normalizes no to 0' do
        get_value_from_db(:yesnoes, :no).should == 'false'
      end

    end

  end

  # store values under raw_#{context} just to make sure we're not getting
  # anything from the previous tests
  describe 'getting from db' do

    def insert_into_db(id, context, key, val)
      keys   = %w(settable_type settable_id context key value)
      values = "'" + ['TunableModel', id, "raw_#{context}", key, val].join("','") + "'"
      sql = "REPLACE INTO `settings` (#{keys.join(', ')}) VALUES (#{values});"
      ActiveRecord::Base.connection.execute(sql)
    end

    before do
      VALUE_TYPES.each do |context, values|
        values.each do |key, val|
          insert_into_db(@model.id, context, key, val)
        end
      end
    end

    def get_value_from_db_from_model(context, key)
      settings = @model.reload.settings_hash
      ctx = "raw_#{context}".to_sym
      settings[ctx][key]
    end

    it 'normalizes 1 to true' do
      get_value_from_db_from_model(:numbers, :number_1).should === 1
    end

    it 'normalizes 0 to false' do
      get_value_from_db_from_model(:numbers, :number_0).should === 0
    end

    it 'keeps 666 as 666' do
      get_value_from_db_from_model(:numbers, :number_of_the_beast).should == 666
    end

    it 'keeps foo as foo' do
      get_value_from_db_from_model(:main, :foo).should == 'foo'
    end

    it 'normalizes booleany true values to true' do
      get_value_from_db_from_model(:main, :truthy).should === true
    end

    it 'normalizes booleany false values to false' do
      get_value_from_db_from_model(:main, :falsy).should === false
    end

    it 'normalizes t (from true) to true' do
      get_value_from_db_from_model(:main, :t).should === true
    end

    it 'normalizes f (from false) to false' do
      get_value_from_db_from_model(:main, :f).should === false
    end

    it 'normalizes on to true' do
      get_value_from_db_from_model(:onoffs, :on).should === true
    end

    it 'normalizes off to false' do
      get_value_from_db_from_model(:onoffs, :off).should === false
    end

    it 'normalizes y to true' do
      get_value_from_db_from_model(:yesnoes, :y).should === true
    end

    it 'normalizes n to false' do
      get_value_from_db_from_model(:yesnoes, :n).should === false
    end

    it 'normalizes yes to true' do
      get_value_from_db_from_model(:yesnoes, :yes).should === true
    end

    it 'normalizes no to false' do
      get_value_from_db_from_model(:yesnoes, :no).should === false
    end

  end

end
