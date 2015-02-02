require 'spec_helper'

describe GunBroker::Item do

  let(:attrs) { JSON.parse(response_fixture('item')) }

  it 'should have an #id' do
    item = GunBroker::Item.new(attrs)
    expect(item.id).to eq(attrs['itemID'])
  end

  context '#[]' do
    it 'should return the value from @attrs' do
      item = GunBroker::Item.new(attrs)
      attrs.each { |k, v| expect(item[k]).to eq(v) }
    end
  end

  context '.find' do
    let(:attrs) { JSON.parse(response_fixture('item')) }
    let(:endpoint) { [GunBroker::API::GUNBROKER_API, "/Items/#{attrs['itemID']}"].join }

    context 'on success' do
      it 'returns an Item' do
        stub_request(:get, endpoint)
          .with(headers: headers)
          .to_return(body: response_fixture('item'))

        id = attrs['itemID']
        item = GunBroker::Item.find(id)
        expect(item).to be_a(GunBroker::Item)
        expect(item.id).to eq(id)
      end
    end

    context 'on failure' do
      it 'should raise an exception' do
        stub_request(:get, endpoint)
          .with(headers: headers)
          .to_return(body: response_fixture('empty'), status: 404)

        expect { GunBroker::Item.find(attrs['itemID']) }.to raise_error(GunBroker::Error::RequestError)
      end
    end
  end

end
