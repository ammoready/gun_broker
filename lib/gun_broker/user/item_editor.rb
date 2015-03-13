require 'gun_broker/token_header'

module GunBroker
  class User
    # TODO: On second thought, this class is pretty dumb.  Move the #create methods to ItemsDelegate.
    class ItemEditor

      include GunBroker::TokenHeader

      # @param user [User] A {User} instance.
      # @param params [Hash] The Item attributes.
      def initialize(user, params)
        @user = user
        @params = params
      end

      # Sends a multipart/form-data POST request to create an Item with the given `@params`.
      # @return [GunBroker::Item] A {Item} instance or `false` if the item could not be created.
      def create
        create!
      rescue GunBroker::Error
        false
      end

      # Same as {#create} but raises GunBroker::Error::RequestError on failure.
      # @raise [GunBroker::Error::NotAuthorized] If the {User#token `@user` token} isn't valid.
      # @raise [GunBroker::Error::RequestError] If the Item attributes are not valid or required attributes are missing.
      # @return [GunBroker::Item] A {Item} instance.
      def create!
        response = GunBroker::API.multipart_post('/Items', @params, token_header(@user.token))
        item_id = response.body['links'].first['title']
        GunBroker::Item.find(item_id)
      end

    end
  end
end
