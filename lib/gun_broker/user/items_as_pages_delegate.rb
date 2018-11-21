require 'gun_broker/token_header'

module GunBroker
  class User
    # Used to scope {ItemsAsPage} actions by {User}.
    class ItemsAsPagesDelegate

      include GunBroker::TokenHeader

      # @param user [User] A {User} instance to scope item pages by.
      # @param options [Hash] { items_per_page => <number of desired items per page> (Integer) }.
      def initialize(user, options = {})
        max_page_size = GunBroker::API::PAGE_SIZE
        @user = user
        @items_per_page = options.fetch(:items_per_page, max_page_size)

        if @items_per_page > max_page_size
          raise ArgumentError.new("`items_per_page` may not exceed #{max_page_size}")
        end
      end

      # Returns pages for all the the User's items (both selling and not selling).
      # @note {API#get! GET} /Items
      # @return [Array<ItemsAsPage>]
      def all
        # NOTE: this endpoint will not return items that were sold
        @all ||= build_pages_for(:Items, params_for(:sellername))
      end

      # Returns pages for all items the User has bid on.
      # @note {API#get! GET} /ItemsBidOn
      # @return [Array<ItemsAsPage>]
      def bid_on
        @bid_on ||= build_pages_for(:ItemsBidOn)
      end

      # Returns pages for items the User has bid on, but not won.
      # @note {API#get! GET} /ItemsNotWon
      # @return [Array<ItemsAsPage>]
      def not_won(options = {})
        @not_won ||= build_pages_for(:ItemsNotWon, params_for(:timeframe, options))
      end

      # Returns pages for items that are currently selling.
      # @note {API#get! GET} /Items
      # @return [Array<ItemsAsPage>]
      def selling
        @selling ||= build_pages_for(:Items, params_for(:sellername))
      end

      # Returns pages for items the User has sold.
      # @note {API#get! GET} /ItemsSold
      # @return [Array<ItemsAsPage>]
      def sold(options = {})
        @sold ||= build_pages_for(:ItemsSold, params_for(:timeframe, options))
      end

      # Returns pages for items that were listed, but not sold.
      # @note {API#get! GET} /ItemsUnsold
      # @return [Array<ItemsAsPage>]
      def unsold(options = {})
        @unsold ||= build_pages_for(:ItemsUnsold, params_for(:timeframe, options))
      end

      # Returns pages for items the User has won.
      # @note {API#get! GET} /ItemsWon
      # @return [Array<ItemsAsPage>]
      def won(options = {})
        @won ||= build_pages_for(:ItemsWon, params_for(:timeframe, options))
      end

      private

      def build_pages_for(endpoint, params = {})
        endpoint = ['/', endpoint.to_s].join
        _token_header = token_header(@user.token)
        response = GunBroker::API.get(endpoint, params.merge({ 'PageSize' => 1 }), _token_header)
        number_of_pages = (response['count'] / @items_per_page.to_f).ceil
        items_as_pages = []

        number_of_pages.times do |page_number|
          page_number += 1
          attrs = {
            page_size:    @items_per_page,
            page_index:   page_number,
            endpoint:     endpoint,
            params:       params,
            token_header: _token_header
          }

          items_as_pages << GunBroker::ItemsAsPage.new(attrs)
        end

        items_as_pages
      end

      def params_for(key, options = {})
        case key
        when :sellername
          { 'SellerName' => @user.username }
        when :timeframe
          { 'TimeFrame' => (options[:timeframe] || GunBroker::API::MAX_ITEMS_TIME_FRAME) }
        else
          raise GunBroker::Error.new 'Unrecognized `params_for` key.'
        end
      end

    end
  end
end
