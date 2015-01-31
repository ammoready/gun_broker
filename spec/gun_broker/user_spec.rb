require 'spec_helper'

describe GunBroker::User do
  let(:username) { 'test-user' }
  let(:password) { 'sekret-passw0rd' }
  let(:token)    { 'test-user-access-token' }

  before(:all) do
    GunBroker.dev_key = 'test-dev-key'
  end

  context '#initialize' do
    context 'auth_options' do
      it 'should accept a password' do
        user = GunBroker::User.new(username, password: password)
        expect(user.instance_variable_get(:@username)).to eq(username)
      end

      it 'should accept an access token' do
        user = GunBroker::User.new(username, token: token)
        expect(user.token).to eq(token)
      end
    end
  end

  context '#authenticate!' do
    let(:endpoint) { [GunBroker::API::GUNBROKER_API, '/Users/AccessToken'].join }

    context 'on success' do
      it 'should set the access token' do
        stub_request(:post,  endpoint)
          .with(
            headers: headers,
            body: { username: username, password: password },
          )
          .to_return(body: { 'accessToken' => token }.to_json)

        user = GunBroker::User.new(username, password: password)
        user.authenticate!

        expect(user.token).to eq(token)
      end
    end

    context 'on failure' do
      it 'should raise a GunBroker::Error::NotAuthorized exception' do
        stub_request(:post, endpoint)
          .with(
            headers: headers,
            body: { username: username, password: password }
          ).to_return(body: response_fixture('not_authorized'), status: 401)

        user = GunBroker::User.new(username, password: password)
        expect { user.authenticate! }.to raise_error(GunBroker::Error::NotAuthorized)
      end
    end
  end

  context '#deauthenticate!' do
    let(:endpoint) { [GunBroker::API::GUNBROKER_API, '/Users/AccessToken'].join }

    context 'on success' do
      it 'should deactivate the current access token' do
        user = GunBroker::User.new(username, token: token)

        stub_request(:delete, endpoint)
          .with(headers: headers)
          .to_return(body: response_fixture('deauthenticate'))

        expect(user.deauthenticate!).to eq(true)
        expect(user.token).to be_nil
      end
    end

    context 'on failure' do
      it 'should raise an exception' do
        user = GunBroker::User.new(username, token: token)

        stub_request(:delete, endpoint)
          .with(headers: headers)
          .to_return(body: response_fixture('not_authorized'), status: 401)

        expect { user.deauthenticate! }.to raise_error(GunBroker::Error::NotAuthorized)
      end
    end

    it 'should have a #revoke_access_token! alias' do
      user = GunBroker::User.new(username, token: token)

      stub_request(:delete, endpoint)
        .with(headers: headers)
        .to_return(body: response_fixture('deauthenticate'))

      expect(user.revoke_access_token!).to eq(true)
      expect(user.token).to be_nil
    end
  end

  context '#items' do
    let(:endpoint) { [GunBroker::API::GUNBROKER_API, '/Items'].join }

    context 'on success' do
      it 'returns the User items' do
        stub_request(:get, endpoint)
          .with(
            headers: headers('X-AccessToken' => token),
            query: { 'SellerName' => username }
          )
          .to_return(body: response_fixture('items'))

        user = GunBroker::User.new(username, token: token)
        expect(user.items).not_to be_empty
        expect(user.items.first).to be_a(GunBroker::Item)
      end
    end

    context 'on failure' do
      it 'should raise an exception' do
        stub_request(:get, endpoint)
          .with(
            headers: headers('X-AccessToken' => token),
            query: { 'SellerName' => username }
          )
          .to_return(body: response_fixture('not_authorized'), status: 401)

        user = GunBroker::User.new(username, token: token)
        expect { user.items }.to raise_error(GunBroker::Error::NotAuthorized)
      end
    end
  end

  context '#items_unsold' do
    let(:endpoint) { [GunBroker::API::GUNBROKER_API, '/ItemsUnsold'].join }

    context 'on success' do
      it 'returns unsold Items' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('items'))

        user = GunBroker::User.new(username, token: token)
        expect(user.items_unsold).not_to be_empty
        expect(user.items_unsold.first).to be_a(GunBroker::Item)
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('not_authorized'), status: 401)

        user = GunBroker::User.new(username, token: token)
        expect { user.items_unsold }.to raise_error(GunBroker::Error::NotAuthorized)
      end
    end
  end

  context '#items_sold' do
    let(:endpoint) { [GunBroker::API::GUNBROKER_API, '/ItemsSold'].join }

    context 'on success' do
      it 'returns sold Items' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('items'))

        user = GunBroker::User.new(username, token: token)
        expect(user.items_sold).not_to be_empty
        expect(user.items_sold.first).to be_a(GunBroker::Item)
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('not_authorized'), status: 401)

        user = GunBroker::User.new(username, token: token)
        expect { user.items_sold }.to raise_error(GunBroker::Error::NotAuthorized)
      end
    end
  end

  context '#items_won' do
    let(:endpoint) { [GunBroker::API::GUNBROKER_API, '/ItemsWon'].join }

    context 'on success' do
      it 'returns won Items' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('items'))

        user = GunBroker::User.new(username, token: token)
        expect(user.items_won).not_to be_empty
        expect(user.items_won.first).to be_a(GunBroker::Item)
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('not_authorized'), status: 401)

        user = GunBroker::User.new(username, token: token)
        expect { user.items_won }.to raise_error(GunBroker::Error::NotAuthorized)
      end
    end
  end

end
