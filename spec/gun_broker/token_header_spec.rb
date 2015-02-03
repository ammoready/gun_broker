require 'spec_helper'

describe GunBroker::TokenHeader do

  let(:mock_class) { (Class.new { include GunBroker::TokenHeader }).new }

  context '#token_header' do
    it 'returns the access token Hash' do
      token = 'test-user-access-token'
      header = { 'X-AccessToken' => token }
      expect(mock_class.send(:token_header, token)).to eq(header)
    end

    it 'raises an exception if token is nil' do
      expect {
        mock_class.send(:token_header, nil)
      }.to raise_error(GunBroker::Error)
    end
  end

end
