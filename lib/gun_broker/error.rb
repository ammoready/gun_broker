module GunBroker
  class Error < StandardError

    class NotAuthorized < GunBroker::Error; end
    class NotFound < GunBroker::Error; end
    class RequestError < GunBroker::Error; end

  end
end
