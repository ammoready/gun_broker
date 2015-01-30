require 'spec_helper'

describe GunBroker::User do
  let(:username) { 'test-user' }
  let(:password) { 'sekret-passw0rd' }

  let(:headers) { { 'Content-Type' => 'application/json', 'X-DevKey' => GunBroker.dev_key } }

  before(:all) do
    GunBroker.dev_key = 'random-dev-key'
  end

  context '#authenticate!' do
    let(:endpoint) { [GunBroker::API::GUNBROKER_API, '/Users/AccessToken'].join }

    context 'on success' do
      it 'should set the access token' do
        token    = 'random-user-access-token'

        stub_request(:post,  endpoint)
          .with(
            headers: headers,
            body: { username: username, password: password },
          )
          .to_return(body: { 'accessToken' => token }.to_json)

        user = GunBroker::User.new(username, password)
        user.authenticate!

        expect(user.token).to eq(token)
      end
    end

    context 'on failure' do
      it 'should raise a GunBroker::Error::RequestError exception' do
        stub_request(:post, endpoint)
          .with(
            headers: headers,
            body: { username: username, password: password }
          ).to_return(body: response_fixture('not_authorized'), status: 401)

        user = GunBroker::User.new(username, password)
        expect { user.authenticate! }.to raise_error(GunBroker::Error::RequestError)
      end
    end
  end

  context 'deauthenticate!' do
    let(:endpoint) { [GunBroker::API::GUNBROKER_API, '/Users/AccessToken'].join }

    context 'on success' do
      it 'should deactivate the current access token' do
        user = GunBroker::User.new(username, password)

        stub_request(:delete, endpoint)
          .with(headers: headers)
          .to_return(body: response_fixture('deauthenticate'))

        user.deauthenticate!
        expect(user.token).to be_nil
      end
    end

    context 'on failure' do
      it 'should raise an exception' do
        user = GunBroker::User.new(username, password)

        stub_request(:delete, endpoint)
          .with(headers: headers)
          .to_return(body: response_fixture('not_authorized'), status: 401)

        expect { user.deauthenticate! }.to raise_error(GunBroker::Error::RequestError)
      end
    end
  end

  context '#items' do
    let(:endpoint) { [GunBroker::API::GUNBROKER_API, '/Items'].join }

    context 'on success' do
      it 'returns the User items' do
        stub_request(:get, endpoint)
          .with(
            headers: headers,
            query: { 'SellerName' => username }
          )
          .to_return(body: response_fixture('items'))

        user = GunBroker::User.new(username, password)
        expect(user.items).not_to be_empty
        expect(user.items.first).to be_a(GunBroker::Item)
      end
    end

    context 'on failure' do
      it 'should raise an exception' do
        stub_request(:get, endpoint)
          .with(
            headers: headers,
            query: { 'SellerName' => username }
          )
          .to_return(body: response_fixture('not_authorized'), status: 401)

        user = GunBroker::User.new(username, password)
        expect { user.items }.to raise_error(GunBroker::Error::RequestError)
      end
    end
  end
end
