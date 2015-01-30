require 'spec_helper'

describe GunBroker do

  it 'has a VERSION' do
    expect(GunBroker::VERSION).to be_a(String)
  end

  context 'dev_key' do
    let(:key) { 'foo' }

    it 'sets @@dev_key' do
      GunBroker.dev_key = key
      expect(GunBroker.class_variable_get(:@@dev_key)).to eq(key)
    end

    it 'returns @@dev_key' do
      GunBroker.dev_key = key
      expect(GunBroker.dev_key).to eq(key)
    end
  end

end