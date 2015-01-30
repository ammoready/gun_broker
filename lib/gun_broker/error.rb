module GunBroker
  class Error < StandardError

    class NotAuthorized < StandardError; end
    class RequestError < StandardError; end

  end
end
