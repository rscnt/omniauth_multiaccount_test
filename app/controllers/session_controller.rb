require 'soundcloud'
require 'boxnet'
require 'json'

class SessionController < ApplicationController
    def new
        provider_name = params[:provider]
        if provider_name
            redirect_to "/auth/#{provider_name}"
        end
    end

    def create
        auth = request.env['omniauth.auth']
        @credential = Credential.find_with_omniauth(auth)

        if @credential.nil?
          @credential = Credential.create_with_omniauth(auth)
        end

        if signed_in?
          if @credential.user == current_user
            # user signed in trying to link with other account
            redirect_to root_url, notice: "Already logged in"
          else
            # the credential is not associated with the current_user so lets
            # associate the indentity
            @credential.user = current_user
            @credential.save()
            redirect_to root_url, notice: "Associate with new credential #{@credential.provider}"
          end
        else
          if @credential.user.present?
            # the credential has an user, but user not logged
            self.current_user = @credential.user
            redirect_to root_url, notice: "Signed in as user id #{@credential.user.id}"
          else
            # create a new user and associate this new credential
            self.current_user = User.create_with_omniauth(auth)
            redirect_to root_url, notice: "User is now an user #{self.current_user.id}"
          end
        end

        if @credential.provider == "soundcloud"
          client = SoundCloud.new(:access_token => @credential.token)
          puts client.get('/me')
        else
          client = BoxNet.new(:access_token => @credential.token, :use_ssl => true)
          begin
            respns = client.post('/folders', {:name => 'ndurnz_2', :parent => {:id => '0'}}.to_json)
          rescue
            client.exchange_token{client_id: OMNIAUTH_CONFIG['box_client_id'], client_secret: OMNIAUTH_CONFIG['box_client_secret']}
          end
          puts  respns
          puts client.get('/users/me')

        end
    end

    def destroy
        reset_session
        redirect_to root_url, notice: 'Signed out!'
    end
end
