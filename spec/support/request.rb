require 'gun_broker/api'

module GunBroker
  module Test
    module Request

      AUTH_ENDPOINT = [GunBroker::API::ROOT_URL, '/Users/AccessToken'].join

      def stub_authentication(username, password)
        stub_request(:post, AUTH_ENDPOINT)
          .with(
            headers: headers,
            body: { username: username, password: password },
          )
          .to_return(body: { 'accessToken' => token }.to_json)
      end

      def stub_authentication_failure(username, password)
        stub_request(:post, AUTH_ENDPOINT)
          .with(
            headers: headers,
            body: { username: username, password: password },
          ).to_return(body: response_fixture('not_authorized'), status: 401)
      end

    end
  end
end
