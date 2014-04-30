class User < ActiveRecord::Base
    has_many :credential
    
    def self.create_with_omniauth(omniauth_hash)
        user_params = {
            :name     => omniauth_hash['info']['name'],
            :nickname => omniauth_hash['info']['nickname'],
            :email    => omniauth_hash['info']['email']
        }
        user = User.create(user_params)
        credential_params = {
            :uid      => omniauth_hash['uid'],
            :provider => omniauth_hash['provider'],
            :token    => omniauth_hash['credentials']['token'],
            :expire   => true,
            :user_id  => user.id
        }
        credential = Credential.create(credential_params)
        if credential
            return user
        # raise Exception
        end
    end
end
