require 'spec_helper'

describe GunBroker::API do

  let(:token) { 'test-user-access-token' }

  let(:path)     { '/some/resource' }
  let(:endpoint) { [GunBroker::API::GUNBROKER_API, path].join }

  before(:all) do
    GunBroker.dev_key = 'test-dev-key'
  end

  it 'has a GUNBROKER_API constant' do
    expect(GunBroker::API::GUNBROKER_API).not_to be_nil
  end

  context '.delete' do
    context 'on success' do
      it 'returns JSON parsed response' do
        stub_request(:delete, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('deauthenticate'))

        response = GunBroker::API.delete(path, {}, headers('X-AccessToken' => token))
        expect(response).to eq(JSON.parse(response_fixture('deauthenticate')))
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:delete, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('empty'), status: 500)

        api = GunBroker::API.new(path, {}, headers('X-AccessToken' => token))
        expect { api.delete! }.to raise_error(GunBroker::Error::RequestError)
      end
    end
  end

  context '.get' do
    context 'on success' do
      it 'returns JSON parsed response' do
        stub_request(:get, endpoint)
          .with(query: { 'SellerName' => 'test-user' })
          .to_return(body: response_fixture('items'))

        response = GunBroker::API.get(path, { 'SellerName' => 'test-user' })
        expect(response).to eq(JSON.parse(response_fixture('items')))
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:get, endpoint)
          .to_return(body: response_fixture('empty'), status: 500)

        api = GunBroker::API.new(path)
        expect { api.get! }.to raise_error(GunBroker::Error::RequestError)
      end
    end
  end

  context '.post' do
    context 'on success' do
      it 'returns JSON parsed response' do
        stub_request(:post, endpoint)
          .with(
            headers: headers,
            body: { username: 'test-user' }
          )
          .to_return(body: response_fixture('authenticate'))

        response = GunBroker::API.post(path, { username: 'test-user' }, headers)
        expect(response).to eq(JSON.parse(response_fixture('authenticate')))
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:post, endpoint)
          .to_return(body: response_fixture('empty'), status: 500)

        api = GunBroker::API.new(path)
        expect { api.post! }.to raise_error(GunBroker::Error::RequestError)
      end
    end
  end

end
