require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'setting on/off?' do

  VALUE_TYPES = {
    :main => {
      :truthy => 'true',
      :falsy  => 'false',
      :t      => 't',
      :f      => 'f',
      :foo    => 'foo',
      :empty  => ''
    },
    :numbers => {
      :number_0 => '0',
      :number_1 => '1',
      :number_of_the_beast => '666'
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

  before :all do
    load_main_settings!
    @model = TunableModel.create(name: "Yay, I'm settable!")

    # Raw values (not normalized) need to be stored into db
    # to check if settings on/off is backwards compatible
    def insert_into_db(id, context, key, val)
      keys   = %w(settable_type settable_id context key value)
      values = "'" + ['TunableModel', id, "#{context}", key, val].join("','") + "'"
      sql = "REPLACE INTO `settings` (#{keys.join(', ')}) VALUES (#{values});"
      ActiveRecord::Base.connection.execute(sql)
    end

    VALUE_TYPES.each do |context, values|
      values.each do |key, val|
        insert_into_db(@model.id, context, key, val)
      end
    end
  end

  describe 'setting_on?' do

    describe 'with nonexisting key' do

      it 'returns nil' do
        @model.setting_on?(:main, :not_a_real_key).should === false
      end

    end

    describe 'with empty value' do

      it 'returns nil' do
        @model.setting_on?(:main, :empty).should === false
      end

    end

    describe 'with foo value' do

      it 'returns false' do
        @model.setting_on?(:main, :foo).should === false
      end

    end

    describe 'with numeric value other than 0/1' do

      it 'returns false' do
        @model.setting_on?(:numbers, :number_of_the_beast).should === false
      end

    end

    describe 'with falsy value' do

      describe 'false' do
        it 'returns false' do
          @model.setting_on?(:main, :falsy).should === false
        end
      end

      describe '0' do
        it 'returns false' do
          @model.setting_on?(:numbers, :number_0).should === false
        end
      end

      describe 'off' do
        it 'returns false' do
          @model.setting_on?(:onoffs, :off).should === false
        end
      end

      describe 'no' do
        it 'returns false' do
          @model.setting_on?(:yesnoes, :no).should === false
        end
      end

      describe 'n' do
        it 'returns false' do
          @model.setting_on?(:yesnoes, :n).should === false
        end
      end

    end

    describe 'with truthy value' do

      describe 'true' do
        it 'returns true' do
          @model.setting_on?(:main, :truthy).should === true
        end
      end

      describe '1' do
        it 'returns true' do
          @model.setting_on?(:numbers, :number_1).should === true
        end
      end

      describe 'on' do
        it 'returns true' do
          @model.setting_on?(:onoffs, :on).should === true
        end
      end

      describe 'yes' do
        it 'returns true' do
          @model.setting_on?(:yesnoes, :yes).should === true
        end
      end

      describe 'y' do
        it 'returns true' do
          @model.setting_on?(:yesnoes, :y).should === true
        end
      end

    end

  end

  describe 'setting_off?' do

    describe 'with nonexisting key' do

      it 'returns nil' do
        @model.setting_off?(:main, :not_a_real_key).should === false
      end

    end

    describe 'with empty value' do

      it 'returns nil' do
        @model.setting_off?(:main, :empty).should === false
      end

    end

    describe 'with foo value' do

      it 'returns false' do
        @model.setting_off?(:main, :foo).should === false
      end

    end

    describe 'with numeric value other than 0/1' do

      it 'returns false' do
        @model.setting_off?(:numbers, :number_of_the_beast).should === false
      end

    end

    describe 'with falsy value' do

      describe 'false' do
        it 'returns true' do
          @model.setting_off?(:main, :falsy).should === true
        end
      end

      describe '0' do
        it 'returns true' do
          @model.setting_off?(:numbers, :number_0).should === true
        end
      end

      describe 'off' do
        it 'returns true' do
          @model.setting_off?(:onoffs, :off).should === true
        end
      end

      describe 'no' do
        it 'returns true' do
          @model.setting_off?(:yesnoes, :no).should === true
        end
      end

      describe 'n' do
        it 'returns true' do
          @model.setting_off?(:yesnoes, :n).should === true
        end
      end

    end

    describe 'with truthy value' do

      describe 'true' do
        it 'returns false' do
          @model.setting_off?(:main, :truthy).should === false
        end
      end

      describe '1' do
        it 'returns false' do
          @model.setting_off?(:numbers, :number_1).should === false
        end
      end

      describe 'on' do
        it 'returns false' do
          @model.setting_off?(:onoffs, :on).should === false
        end
      end

      describe 'yes' do
        it 'returns false' do
          @model.setting_off?(:yesnoes, :yes).should === false
        end
      end

      describe 'y' do
        it 'returns false' do
          @model.setting_off?(:yesnoes, :y).should === false
        end
      end

    end

  end

end
