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
        credential = Credential.find_by(provider: credential_params[:provider],
                                        uid: credential_params[:uid])
        if !!credential
          if credential.user_id.nil?
            user = User.create(name: user_params[:name], nickname:
                               omniauth_hash[:nickname], email:
                               omniauth_hash[:email])
            credential.user_id = user.id
            credential.save
            user
          end
        else
        end
    end
end
