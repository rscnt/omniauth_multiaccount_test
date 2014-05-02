class Credential < ActiveRecord::Base
  belongs_to :user

  def self.find_with_omniauth(omniauth_hash)
    find_by provider: omniauth_hash['provider'], uid: omniauth_hash['uid']
  end


  def self.create_with_omniauth(omniauth_hash)
    create(uid: omniauth_hash['uid'], provider: omniauth_hash['provider'], token: omniauth_hash['credentials']['token'], refresh_token: omniauth_hash['credentials']['refresh_token'], expire: omniauth_hash['credentials']['expires'])
  end

end
