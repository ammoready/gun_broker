require 'spec_helper'

describe GunBroker::Item do

  let(:attrs) { JSON.parse(response_fixture('item')) }

  it 'should have an #id' do
    item = GunBroker::Item.new(attrs)
    expect(item.id).to eq(attrs['itemID'])
  end

end
