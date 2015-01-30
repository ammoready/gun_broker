module GunBroker
  module Test
    module Headers

      def headers(overrides = {})
        {
          'Content-Type' => 'application/json',
          'X-DevKey' => GunBroker.dev_key
        }.merge(overrides)
      end

    end
  end
end
