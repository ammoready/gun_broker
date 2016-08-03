require 'spec_helper'

describe GunBroker do

  it 'has a VERSION' do
    expect(GunBroker::VERSION).to be_a(String)
  end

  context '.base_url' do
    context 'in sandbox mode' do
      it 'should return the proper sandbox api url' do
        GunBroker.sandbox = false
        expect(GunBroker.base_url).to eq("https://api.gunbroker.com/v1")
        expect(GunBroker.base_url(api: false)).to eq("https://www.gunbroker.com")
      end
    end

    context 'in live mode' do
      it 'should return the proper api url' do
        GunBroker.sandbox = true
        expect(GunBroker.base_url).to eq("https://api.sandbox.gunbroker.com/v1")
        expect(GunBroker.base_url(api: false)).to eq("https://www.sandbox.gunbroker.com")
      end
    end
  end

  context '.dev_key' do
    let(:key) { 'foo' }

    it 'sets @@dev_key' do
      GunBroker.dev_key = key
      expect(GunBroker.class_variable_get(:@@dev_key)).to eq(key)
    end

    it 'returns @@dev_key' do
      GunBroker.dev_key = key
      expect(GunBroker.dev_key).to eq(key)
    end

    it 'raises an exception if @@dev_key is nil' do
      GunBroker.class_variable_set(:@@dev_key, nil)
      expect { GunBroker.dev_key }.to raise_error(GunBroker::Error)
    end
  end

  context '.sandbox' do
    it 'sets @@sandbox to true' do
      GunBroker.sandbox = true
      expect(GunBroker.sandbox).to eq(true)
      expect(GunBroker.sandbox?).to eq(true)
    end
  end

  context '.time' do
    before(:all) do
      GunBroker.sandbox = false
      GunBroker.dev_key = 'test-dev-key'
    end

    let(:endpoint) { [GunBroker::API::ROOT_URL, '/GunBrokerTime'].join }
    let(:response) { JSON.parse(response_fixture('time')) }

    it 'should return the GunBroker time' do
      stub_request(:get, endpoint)
        .with(headers: headers)
        .to_return(body: response_fixture('time'))

      time = GunBroker.time
      expect(time['gunBrokerTime']).to eq(response['gunBrokerTime'])
      expect(time['gunBrokerVersion']).to eq(response['gunBrokerVersion'])
    end
  end

  context '.timeout' do
    before(:all) do
      GunBroker.sandbox = true
      GunBroker.dev_key = 'test-dev-key'
    end

    it 'sets @@timeout' do
      GunBroker.timeout = 15
      expect(GunBroker.class_variable_get(:@@timeout)).to eq(15)
    end

    it 'returns @@timeout' do
      GunBroker.timeout = 15
      expect(GunBroker.timeout).to eq(15)
    end
  end

end
