require 'spec_helper'

describe GunBroker::Item::Constants do

  it 'has a AUTO_RELIST hash' do
    expect(GunBroker::Item::AUTO_RELIST).to be_a(Hash)
  end

  it 'has a CONDITION hash' do
    expect(GunBroker::Item::CONDITION).to be_a(Hash)
  end

  it 'has a INSPECTION_PERIOD hash' do
    expect(GunBroker::Item::INSPECTION_PERIOD).to be_a(Hash)
  end

  it 'has a LISTING_DURATION hash' do
    expect(GunBroker::Item::LISTING_DURATION).to be_a(Hash)
  end

  it 'has a PAYMENT_METHODS hash' do
    expect(GunBroker::Item::PAYMENT_METHODS).to be_a(Hash)
  end

  it 'has a SHIPPING_CLASSES hash' do
    expect(GunBroker::Item::SHIPPING_CLASSES).to be_a(Hash)
  end

  it 'has a SHIPPING_PAYER hash' do
    expect(GunBroker::Item::SHIPPING_PAYER).to be_a(Hash)
  end

end
