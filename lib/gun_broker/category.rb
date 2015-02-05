module GunBroker
  # Represents a GunBroker category.
  class Category

    # The top-level category ID.
    ROOT_CATEGORY_ID = 0

    # @param parent [Integer, String] (optional) Return all subcategories of the given parent Category ID; defaults to the root (top-level) categories.
    # @return [Array<Category>] An array of GunBroker::Category instances.
    def self.all(parent = ROOT_CATEGORY_ID)
      response = GunBroker::API.get('/Categories', { 'ParentCategoryID' => parent })
      response['results'].map { |attrs| new(attrs) }
    end

    # @param category_id [Integer, String] The ID of the Category to find.
    # @return [Category] A Category instance or `nil` if no Category with `category_id` exists.
    def self.find(category_id)
      find!(category_id)
    rescue GunBroker::Error::NotFound
      nil
    end

    # Same as {.find} but raises GunBroker::Error::NotFound if no Category is found.
    # @param (see .find)
    # @raise [GunBroker::Error::NotFound] If no Category with `category_id` exists.
    # @return (see .find)
    def self.find!(category_id)
      new(GunBroker::API.get("/Categories/#{category_id}"))
    end

    # @param attrs [Hash] The JSON attributes from the API response.
    def initialize(attrs = {})
      @attrs = attrs
    end

    # @return [Integer] The Category ID.
    def id
      @attrs['categoryID']
    end

    # @param key [String] A Category attribute name (from the JSON response).
    # @return The value of the given `key` or `nil`.
    def [](key)
      @attrs[key]
    end

  end
end
