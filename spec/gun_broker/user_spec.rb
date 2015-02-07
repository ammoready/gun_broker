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

  context '#token_header' do
    it 'raises an error if @token nil' do
      user = GunBroker::User.new(username, token: nil)
      expect { user.items.all }.to raise_error(GunBroker::Error)
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

  context '#contact_info' do
    let(:endpoint) { [GunBroker::API::GUNBROKER_API, '/Users/ContactInfo'].join }

    context 'on success' do
      it 'returns a contact info hash' do
        user = GunBroker::User.new(username, token: token)

        stub_request(:get, endpoint)
          .with(
            headers: headers('X-AccessToken' => token),
            query: { 'UserName' => user.username }
          )
          .to_return(body: response_fixture('contact_info'))

        contact_info = JSON.parse(response_fixture('contact_info'))
        expect(user.contact_info['userID']).to eq(contact_info['userID'])
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        user = GunBroker::User.new(username, token: token)

        stub_request(:get, endpoint)
          .with(
            headers: headers('X-AccessToken' => token),
            query: { 'UserName' => user.username }
          )
          .to_return(body: response_fixture('empty'), status: 401)

        expect { user.contact_info }.to raise_error(GunBroker::Error::NotAuthorized)
      end
    end
  end

  context '#items' do
    it 'should return an ItemsDelegate instance' do
      user = GunBroker::User.new(username, token: token)
      expect(user.items).to be_a(GunBroker::User::ItemsDelegate)
    end
  end

end
