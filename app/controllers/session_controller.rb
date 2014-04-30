class SessionController < ApplicationController
    def new
        provider_name = params[:provider_name]
        if provider_name
            redirect_to "/auth/#{provider_name}"
        else 
            redirect_to "/auth/soundcloud"
        end
    end

    def create
        auth = request.env['omniauth.auth']
        user = User.create_with_omniauth(auth)
        session[:token] = user.credential.last.token
        session[:uid] = user.credential.last.uid
        redirect_to '/', notice => 'Signed in!'
    end


    def destroy
        reset_session
        redirect_to root_url, notice: 'Signed out!'
    end
end