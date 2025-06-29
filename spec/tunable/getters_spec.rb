require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'basic setters' do

  before :all do
    TunableModel.has_settings \
      :website => {
        super_mode: { default: false }
      }

    @model = TunableModel.create(name: "Yay, I'm settable!")
  end


  it 'has getters scoped by context' do
    expect(@model.respond_to?(:website_super_mode)).to eq(true)
    expect(@model.respond_to?(:website_super_mode=)).to eq(true)

    expect(@model.website_super_mode).to eq(false)
    expect(@model.website_super_mode = true).to eq(true)
    expect(@model.website_super_mode).to eq(true)
    @model.save
    expect(@model.website_super_mode).to eq(true)
  end

end