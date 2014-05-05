Rails::application::config.middleware.use OmniAuth::Builder do
    # not the smart way to do it.
    OMNIAUTH_CONFIG = YAML.load_file("#{Rails.root}/config/omniauth_secrets.yml")[Rails.env]
    provider "soundcloud"     , OMNIAUTH_CONFIG['soundclould_client_id'] , OMNIAUTH_CONFIG['soundcloud_client_secret']
    provider "box_oauth2"     , OMNIAUTH_CONFIG['box_client_id']         , OMNIAUTH_CONFIG['box_client_secret']
    provider "dropbox_oauth2" , OMNIAUTH_CONFIG['dropbox_client_id']     , OMNIAUTH_CONFIG['hhqy2dk9b1irpk1']
end
