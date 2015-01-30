require 'spec_helper'

describe GunBroker::API do

  it 'has a GUNBROKER_API constant' do
    expect(GunBroker::API::GUNBROKER_API).not_to be_nil
  end

  context '.delete' do
    context 'on success' do
      it 'returns JSON parsed response'
    end

    context 'on failure' do
      it 'raises an exception'
    end
  end

  context '.get' do
    context 'on success' do
      it 'returns JSON parsed response'
    end

    context 'on failure' do
      it 'raises an exception'
    end
  end

  context '.post' do
    context 'on success' do
      it 'returns JSON parsed response'
    end

    context 'on failure' do
      it 'raises an exception'
    end
  end

end
