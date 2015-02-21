require 'spec_helper'

describe GunBroker::Item do

  let(:attrs) { JSON.parse(response_fixture('item')) }
  let(:item) { GunBroker::Item.new(attrs) }

  it 'should have an #id' do
    expect(item.id).to eq(attrs['itemID'])
  end

  context '#[]' do
    it 'should return the value from @attrs' do
      attrs.each { |k, v| expect(item[k]).to eq(v) }
    end
  end

  context '#attributes' do
    it 'should provide access to @attrs' do
      expect(item.attributes['title']).to eq(attrs['title'])
    end
  end

  context '#category' do
    it 'should return the Category' do
      # Mock up the Category.
      category = GunBroker::Category.new({
        'categoryID' => attrs['categoryID'],
        'categoryName' => attrs['categoryName'],
      })

      expect(GunBroker::Category).to receive(:find).with(attrs['categoryID']).and_return(category)
      expect(item.category).to eq(category)
    end
  end

  context '#title' do
    it 'should return the item title' do
      expect(item.title).to eq(attrs['title'])
    end
  end

  context '.find' do
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
      it 'should return nil' do
        stub_request(:get, endpoint)
          .with(headers: headers)
          .to_return(body: response_fixture('empty'), status: 404)

        expect(GunBroker::Item.find(attrs['itemID'])).to be_nil
      end
    end
  end

  context '.find!' do
    let(:endpoint) { [GunBroker::API::GUNBROKER_API, "/Items/#{attrs['itemID']}"].join }

    context 'on success' do
      it 'returns an Item' do
        stub_request(:get, endpoint)
          .with(headers: headers)
          .to_return(body: response_fixture('item'))

        id = attrs['itemID']
        item = GunBroker::Item.find!(id)
        expect(item).to be_a(GunBroker::Item)
        expect(item.id).to eq(id)
      end
    end

    context 'on failure' do
      it 'should raise GunBroker::Error::NotFound' do
        stub_request(:get, endpoint)
          .with(headers: headers)
          .to_return(body: response_fixture('empty'), status: 404)

        expect { GunBroker::Item.find!(attrs['itemID']) }.to raise_error(GunBroker::Error::NotFound)
      end
    end
  end

  context '#url' do
    it 'returns a fully qualified URL' do
      id = '123'
      item = GunBroker::Item.new({ 'itemID' => id })
      url = "http://www.gunbroker.com/Auction/ViewItem.aspx?Item=#{id}"

      expect(item.url).to eq(url)
    end
  end

end
