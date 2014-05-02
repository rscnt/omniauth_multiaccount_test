require 'soundcloud'
require 'boxnet'

class SessionController < ApplicationController
    def new
        provider_name = params[:provider]
        if provider_name
            redirect_to "/auth/#{provider_name}"
        end
    end

    def create
        auth = request.env['omniauth.auth']
        user = User.create_with_omniauth(auth)
        session[:token] = user.credential.last.token
        session[:uid] = user.credential.last.uid
        box_client = BoxNet.new(:access_token => user.credential.last.token)
        puts box_client.get('/users/me')
        redirect_to '/', notice => 'Signed in!'
    end


    def destroy
        reset_session
        redirect_to root_url, notice: 'Signed out!'
    end
end
