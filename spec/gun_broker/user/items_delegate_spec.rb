require 'spec_helper'

describe GunBroker::User::ItemsDelegate do
  let(:username) { 'test-user' }
  let(:token)    { 'test-user-access-token' }

  let(:user)     { GunBroker::User.new(username, token: token) }
  let(:delegate) { GunBroker::User::ItemsDelegate.new(user) }

  context '#all' do
    let(:endpoint) { [GunBroker::API::ROOT_URL, '/Items'].join }

    context 'on success' do
      it 'returns the User items' do
        stub_request(:get, endpoint)
          .with(
            headers: headers('X-AccessToken' => token),
            query: { 'SellerName' => user.username }
          )
          .to_return(body: response_fixture('items'))

        expect(delegate.all).not_to be_empty
        expect(delegate.all.first).to be_a(GunBroker::Item)
      end
    end

    context 'on failure' do
      it 'should raise an exception' do
        stub_request(:get, endpoint)
          .with(
            headers: headers('X-AccessToken' => token),
            query: { 'SellerName' => user.username }
          )
          .to_return(body: response_fixture('not_authorized'), status: 401)

        expect { delegate.all }.to raise_error(GunBroker::Error::NotAuthorized)
      end
    end
  end

  context '#bid_on' do
    let(:endpoint) { [GunBroker::API::ROOT_URL, '/ItemsBidOn'].join }

    context 'on success' do
      it 'returns won Items' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('items'))

        user = GunBroker::User.new(username, token: token)
        expect(delegate.bid_on).not_to be_empty
        expect(delegate.bid_on.first).to be_a(GunBroker::Item)
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('not_authorized'), status: 401)

        user = GunBroker::User.new(username, token: token)
        expect { delegate.bid_on }.to raise_error(GunBroker::Error::NotAuthorized)
      end
    end
  end

  context '#find' do
    let(:attrs) { JSON.parse(response_fixture('item')) }
    let(:all_endpoint) { [GunBroker::API::ROOT_URL, '/Items'].join }
    let(:endpoint) { [GunBroker::API::ROOT_URL, "/Items/#{attrs['itemID']}"].join }

    it 'returns a single Item' do
      # First, stub the '/Items' request, since we have to use that to scope the Item find by user.
      stub_request(:get, all_endpoint)
        .with(
          headers: headers('X-AccessToken' => token),
          query: { 'SellerName' => user.username }
        )
        .to_return(body: response_fixture('items'))

      # Now we stub the '/Items/:id' request.
      stub_request(:get, endpoint)
        .with(headers: headers)
        .to_return(body: response_fixture('item'))

      item = delegate.find(attrs['itemID'])
      expect(item).to be_a(GunBroker::Item)
      expect(item.id).to eq(attrs['itemID'])
    end

    it 'returns nil if no item found' do
      stub_request(:get, all_endpoint)
        .with(
          headers: headers('X-AccessToken' => token),
          query: { 'SellerName' => user.username }
        )
        .to_return(body: response_fixture('items'))

      expect(delegate.find(666)).to be_nil
    end
  end

  context '#find!' do
    let(:all_endpoint) { [GunBroker::API::ROOT_URL, '/Items'].join }

    it 'calls #find' do
      item_id = 123
      expect(delegate).to receive(:find).with(item_id).and_return(true)
      delegate.find!(item_id)
    end

    it 'raises GunBroker::Error::NotFound if no item found' do
      stub_request(:get, all_endpoint)
        .with(
          headers: headers('X-AccessToken' => token),
          query: { 'SellerName' => user.username }
        )
        .to_return(body: response_fixture('items'))

      item_id = 123
      expect {
        delegate.find!(item_id)
      }.to raise_error(GunBroker::Error::NotFound)
    end
  end

  context '#not_won' do
    let(:endpoint) { [GunBroker::API::ROOT_URL, '/ItemsNotWon'].join }

    context 'on success' do
      it 'returns won Items' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('items'))

        user = GunBroker::User.new(username, token: token)
        expect(delegate.not_won).not_to be_empty
        expect(delegate.not_won.first).to be_a(GunBroker::Item)
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('not_authorized'), status: 401)

        user = GunBroker::User.new(username, token: token)
        expect { delegate.not_won }.to raise_error(GunBroker::Error::NotAuthorized)
      end
    end
  end

  context '#sold' do
    let(:endpoint) { [GunBroker::API::ROOT_URL, '/ItemsSold'].join }

    context 'on success' do
      it 'returns sold Items' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('items'))

        user = GunBroker::User.new(username, token: token)
        expect(delegate.sold).not_to be_empty
        expect(delegate.sold.first).to be_a(GunBroker::Item)
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('not_authorized'), status: 401)

        user = GunBroker::User.new(username, token: token)
        expect { delegate.sold }.to raise_error(GunBroker::Error::NotAuthorized)
      end
    end
  end

  context '#unsold' do
    let(:endpoint) { [GunBroker::API::ROOT_URL, '/ItemsUnsold'].join }

    context 'on success' do
      it 'returns unsold Items' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('items'))

        user = GunBroker::User.new(username, token: token)
        expect(delegate.unsold).not_to be_empty
        expect(delegate.unsold.first).to be_a(GunBroker::Item)
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('not_authorized'), status: 401)

        user = GunBroker::User.new(username, token: token)
        expect { delegate.unsold }.to raise_error(GunBroker::Error::NotAuthorized)
      end
    end
  end

  context '#won' do
    let(:endpoint) { [GunBroker::API::ROOT_URL, '/ItemsWon'].join }

    context 'on success' do
      it 'returns won Items' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('items'))

        user = GunBroker::User.new(username, token: token)
        expect(delegate.won).not_to be_empty
        expect(delegate.won.first).to be_a(GunBroker::Item)
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:get, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('not_authorized'), status: 401)

        user = GunBroker::User.new(username, token: token)
        expect { delegate.won }.to raise_error(GunBroker::Error::NotAuthorized)
      end
    end
  end

end
