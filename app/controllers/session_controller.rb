require 'soundcloud'
require 'box'
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
        puts "Omniauth hahs #{auth.inspect}"
        @credential = Credential.find_with_omniauth(auth)

        if @credential.nil?
          @credential = Credential.create_with_omniauth(auth)
        end

        if signed_in?
          if @credential.user == current_user
            # user signed in trying to link with other account
            redirect_to root_url, notice: "Already logged in with #{@credential.provider} "
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

        case @credential.provider
          when "soundcloud"
            client = SoundCloud.new(:access_token => @credential.token)
            puts client.get('/me/tracks')
          when "box_oauth2"
            client = Box.new(:access_token => @credential.token, :use_ssl => true)
            begin
              respns = client.post('/folders', {:name => 'ndurnz', :parent => {:id => '0'}}.to_json)
              puts "normal response #{respns.inspect}"
            rescue Box::ResponseError => e
              puts "response on error #{e.response.inspect}"
              if e.response.code == 409
                puts e.response.body
              end
            end
            puts  respns
            puts client.get('/users/me')
          when "dropbox_oauth2"
            client = Box.new(:site => 'dropbox.com', :access_token => @credential.token, :use_ssl => true)
            begin
              parent_dir = '/1/metadata/sandbox'
              mresponse = client.get(parent_dir, {:list => true})
              json_dropbox = JSON.parse(mresponse.body)
              contents = json_dropbox['contents']
              audio_mime_type = "audio/mpeg"
              contents.each do |content|
                if content['is_dir'] == true
                  iresponse = client.get("#{parent_dir}#{content['path']}", :list => true)
                  puts iresponse
                end
                if content['mime_type'] == audio_mime_type
                  puts content['path']
                end
              end
            rescue Box::ResponseError => e
              puts e.inspect
              puts e.message
            end
        end
    end

    def destroy
        reset_session
        redirect_to root_url, notice: 'Signed out!'
    end
end
