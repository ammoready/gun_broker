require 'spec_helper'

describe GunBroker::Category do

  let(:attrs) { JSON.parse(response_fixture('category')) }

  before(:all) do
    GunBroker.dev_key = 'test-dev-key'
  end

  it 'has a ROOT_CATEGORY_ID constant' do
    expect(GunBroker::Category::ROOT_CATEGORY_ID).not_to be_nil
  end

  it 'should have an #id' do
    category = GunBroker::Category.new(attrs)
    expect(category.id).to eq(attrs['categoryID'])
  end

  context '.all' do
    let(:endpoint) { [GunBroker::API::GUNBROKER_API, '/Categories'].join }

    context 'on success' do
      it 'returns all categories' do
        stub_request(:get, endpoint)
          .with(
            headers: headers,
            query: { 'ParentCategoryID' => GunBroker::Category::ROOT_CATEGORY_ID }
          )
          .to_return(body: response_fixture('categories'))

        categories = GunBroker::Category.all
        expect(categories).not_to be_empty
        expect(categories.first).to be_a(GunBroker::Category)
      end
    end

    context 'on failure' do
      it 'should raise a GunBroker::Error::RequestError exception' do
        stub_request(:get, endpoint)
          .with(
            headers: headers,
            query: { 'ParentCategoryID' => GunBroker::Category::ROOT_CATEGORY_ID }
          )
          .to_return(body: response_fixture('not_authorized'), status: 401)

        expect { GunBroker::Category.all }.to raise_error(GunBroker::Error::RequestError)
      end
    end
  end

  context '.find' do
    let(:attrs) { JSON.parse(response_fixture('category')) }
    let(:endpoint) { [GunBroker::API::GUNBROKER_API, "/Categories/#{attrs['categoryID']}"].join }

    context 'on success' do
      it 'returns the Category' do
        stub_request(:get, endpoint)
          .with(headers: headers)
          .to_return(body: response_fixture('category'))

        id = attrs['categoryID']
        category = GunBroker::Category.find(id)
        expect(category).to be_a(GunBroker::Category)
        expect(category.id).to eq(id)
      end
    end

    context 'on failure' do
      it 'should raise a GunBroker::Error::RequestError exception' do
        stub_request(:get, endpoint)
          .with(headers: headers)
          .to_return(body: response_fixture('not_authorized'), status: 401)

        id = attrs['categoryID']
        expect { GunBroker::Category.find(id) }.to raise_error(GunBroker::Error::RequestError)
      end
    end
  end

end