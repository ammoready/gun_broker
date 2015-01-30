module GunBroker
  class Category

    # The top-level category ID.
    ROOT_CATEGORY_ID = 0

    def self.all(parent = ROOT_CATEGORY_ID)
      response = GunBroker::API.get('/Categories', { 'ParentCategoryID' => parent })
      response['results'].map { |attrs| new(attrs) }
    end

    def self.find(category_id)
      new(GunBroker::API.get("/Categories/#{category_id}"))
    end

    def initialize(attrs = {})
      @attrs = attrs
    end

    def id
      @attrs['categoryID']
    end

  end
end
