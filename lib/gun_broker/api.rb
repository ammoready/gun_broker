module GunBroker
  class API

    def initialize(path, params = {})
      @path = path
      @params = params
    end

    def self.post(path, params)
      new(path, params).post!
    end

    def post!
      raise 'Not yet implemented.'
    end

  end
end
