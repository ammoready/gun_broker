require 'spec_helper'

describe GunBroker::Feedback do

  let(:attrs) { JSON.parse(response_fixture('feedback')) }

  let(:user_id) { 123 }
  let(:endpoint) { [GunBroker::API::GUNBROKER_API, "/Feedback/#{user_id}"].join }

  context '.all' do
    it 'returns an array of the user feedback' do
      stub_request(:get, endpoint)
        .with(headers: headers)
        .to_return(body: response_fixture('feedback'))
    end
  end

  context '#item' do
    let(:item_id) { attrs['results'].first['itemID'] }
    let(:item_endpoint) { [GunBroker::API::GUNBROKER_API, "/Items/#{item_id}"].join }

    it 'should have an Item' do
      stub_request(:get, endpoint)
        .with(headers: headers)
        .to_return(body: response_fixture('feedback'))

      stub_request(:get, item_endpoint)
        .with(headers: headers)
        .to_return(body: response_fixture('item'))

      all_feedback = GunBroker::Feedback.all(user_id)
      feedback = all_feedback.first

      expect(feedback.item).to be_a(GunBroker::Item)
    end
  end

end
