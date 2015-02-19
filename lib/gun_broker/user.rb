require 'gun_broker/token_header'
require 'gun_broker/user/items_delegate'

module GunBroker
  # Represents a GunBroker User.
  class User

    include GunBroker::TokenHeader

    # @return [String] The User's GunBroker.com username.
    attr_reader :username

    # @return [String] The User's GunBroker access token obtained by calling {#authenticate!} or `nil` if not authenticated.
    attr_reader :token

    # @param username [String]
    # @param auth_options [Hash] Requires either a `:password` or `:token`.
    # @option auth_options [String] :password The User's GunBroker.com password.
    # @option auth_options [String] :token An existing access token previously obtained by calling {#authenticate!} with a username/password.
    def initialize(username, auth_options = {})
      @username = username
      @password = auth_options[:password] || auth_options['password']
      @token    = auth_options[:token]    || auth_options['token']
    end

    # Authenticates with the GunBroker API server and saves the returned access {#token}.
    # @note {API#post! POST} /Users/AccessToken
    # @raise [GunBroker::Error::NotAuthorized] If the username/password is invalid.
    # @raise [GunBroker::Error::RequestError] If there's an issue with the request (usually a `5xx` response).
    # @return [String] The access {#token} used in subsequent requests.
    def authenticate!
      response = GunBroker::API.post('/Users/AccessToken', { username: @username, password: @password })
      @token = response['accessToken']
    end

    # @return [Boolean] `true` if the current credentials are valid.
    def authenticated?
      return false unless has_credentials?
      return !!(authenticate!) if has_password?
      return !!(contact_info) if has_token?  # #contact_info requires a valid token, so use that as a check.
      false
    rescue GunBroker::Error::NotAuthorized
      false
    end

    # Sends a DELETE request to deactivate the current access {#token}.
    # @note {API#delete! DELETE} /Users/AccessToken
    # @raise [GunBroker::Error::RequestError] If there's an issue with the request (usually a `5xx` response).
    # @return [true] Explicitly returns `true` unless an exception is raised.
    def deauthenticate!
      GunBroker::API.delete('/Users/AccessToken', {}, token_header(@token))
      @token = nil
      true  # Explicit `true` so this method won't return the `nil` set above.
    end
    alias_method :revoke_access_token!, :deauthenticate!

    # Returns the User's contact information.
    # @note {API#get! GET} /Users/ContactInfo
    # @raise [GunBroker::Error::RequestError] If there's an issue with the request (usually a `5xx` response).
    # @return [Hash] From the JSON response.
    def contact_info
      GunBroker::API.get('/Users/ContactInfo', { 'UserName' => @username }, token_header(@token))
    end

    # (see ItemsDelegate)
    # See the {ItemsDelegate} docs.
    # @return [ItemsDelegate]
    def items
      ItemsDelegate.new(self)
    end

    private

    # @return [Boolean] `true` if `@username` is present and either `@password` *or* `@token` is present.
    def has_credentials?
      has_username? && (has_password? || has_token?)
    end

    def has_password?
      !@password.nil? && !@password.empty?
    end

    def has_token?
      !@token.nil? && !@token.empty?
    end

    def has_username?
      !@username.nil? && !@username.empty?
    end

  end
end
