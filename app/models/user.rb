class User < ActiveRecord::Base
    has_many :credential

    def self.create_with_omniauth(omniauth_hash)
        user_params = {
            :name     => omniauth_hash['info']['name'],
            :nickname => omniauth_hash['info']['nickname'],
            :email    => omniauth_hash['info']['email']
        }
        credential_params = {
            :uid      => omniauth_hash['uid'],
            :provider => omniauth_hash['provider'],
            :token    => omniauth_hash['credentials']['token'],
            :expire   => true,
            :user_id  => nil
        }
        credential = Credential.where(:provider => credential_params[:provider], :uid => credential_params[:uid])
        # dummy but its done
        user = nil
        if credential.user
            user = User.find(credential.user_id)
        else
            user       = User.create(user_params)
            credential_params[:user_id] = user.id
            credential = Credential.create(credential_params)
        end
        return user
    end
end
