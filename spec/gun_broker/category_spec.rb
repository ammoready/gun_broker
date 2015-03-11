require 'spec_helper'

describe GunBroker::Category do

  let(:attrs) { JSON.parse(response_fixture('category')) }
  let(:category) { GunBroker::Category.new(attrs) }

  before(:all) do
    GunBroker.dev_key = 'test-dev-key'
  end

  it 'has a ROOT_CATEGORY_ID constant' do
    expect(GunBroker::Category::ROOT_CATEGORY_ID).not_to be_nil
  end

  it 'should have an #id' do
    expect(category.id).to eq(attrs['categoryID'])
  end

  it 'should have a #name' do
    expect(category.name).to eq(attrs['categoryName'])
  end

  context '#[]' do
    it 'should return the value from @attrs' do
      attrs.each { |k, v| expect(category[k]).to eq(v) }
    end
  end

  context '.all' do
    let(:endpoint) { [GunBroker::API::ROOT_URL, '/Categories'].join }

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
      it 'should raise a GunBroker::Error::NotAuthorized exception' do
        stub_request(:get, endpoint)
          .with(
            headers: headers,
            query: { 'ParentCategoryID' => GunBroker::Category::ROOT_CATEGORY_ID }
          )
          .to_return(body: response_fixture('not_authorized'), status: 401)

        expect { GunBroker::Category.all }.to raise_error(GunBroker::Error::NotAuthorized)
      end
    end
  end

  context '.find' do
    let(:attrs) { JSON.parse(response_fixture('category')) }
    let(:endpoint) { [GunBroker::API::ROOT_URL, "/Categories/#{attrs['categoryID']}"].join }

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
      it 'should return nil' do
        stub_request(:get, endpoint)
          .with(headers: headers)
          .to_return(body: response_fixture('not_authorized'), status: 404)

        id = attrs['categoryID']
        expect(GunBroker::Category.find(id)).to be_nil
      end
    end
  end

  context '.find!' do
    let(:attrs) { JSON.parse(response_fixture('category')) }
    let(:endpoint) { [GunBroker::API::ROOT_URL, "/Categories/#{attrs['categoryID']}"].join }

    context 'on success' do
      it 'returns the Category' do
        stub_request(:get, endpoint)
          .with(headers: headers)
          .to_return(body: response_fixture('category'))

        id = attrs['categoryID']
        category = GunBroker::Category.find!(id)
        expect(category).to be_a(GunBroker::Category)
        expect(category.id).to eq(id)
      end
    end

    context 'on failure' do
      it 'should raise a GunBroker::Error::NotFound exception' do
        stub_request(:get, endpoint)
          .with(headers: headers)
          .to_return(body: response_fixture('not_authorized'), status: 404)

        id = attrs['categoryID']
        expect { GunBroker::Category.find!(id) }.to raise_error(GunBroker::Error::NotFound)
      end
    end
  end

end
