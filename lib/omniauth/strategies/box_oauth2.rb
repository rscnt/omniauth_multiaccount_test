require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class BoxOAuth2 < OmniAuth::Strategies::OAuth2
      option :name, 'box_oauth2'
      option :client_options, {
        :site => 'https://api.box.com/2.0',
        :authorize_url => 'https://api.box.com/oauth2/authorize',
        :token_method => :post,
        :token_url => 'https://api.box.com/oauth2/token',
        :param_name => 'code',
        :connection_build => (Proc.new do |builder|
          builder.request :multipart
          builder.request :url_encoded
          builder.adapter :net_http
        end)
      }
      option :check_direct_link_support, false

      def callback_url
        super.sub('http:', 'https:')
      end

      def request_phase
        super
      end

      uid { raw_info['id'].to_s }

      info do
        {
          'username' => raw_info['login'],
          'name' => raw_info['name'],
          'email' => raw_info['login'],
          'image' => raw_info['avatar_url']
        }
      end

      extra do
        {:raw_info => raw_info}
      end

      def raw_info
        @raw_info ||= begin
          hash = access_token.get('users/me').parsed
          hash['direct_links'] = false
          # There's no information in the user object that says whether or not
          # the user's account supports direct links
          if options[:check_direct_link_support]
            begin
              # Create a test file to share
              test_filename = "direct_link_test_#{Time.current.to_i}"
              io = StringIO.new("test")
              payload = { :filename => Faraday::UploadIO.new(io, "text/plain", test_filename), :parent_id => 0 }
              resp = access_token.post('files/content', {:body=>payload})
              if resp.status == 201
                # Now try to share that file.
                file_info = resp.parsed['entries'].first
                payload = { :shared_link => {
                    # :unshared_at => Time.current.tomorrow.iso8601,
                    :access => 'open'
                  }}
                resp = access_token.put("files/#{file_info['id']}", {:body=>payload.to_json})
                if resp.status == 200
                  file_info = resp.parsed
                  begin
                    # Check to see if the file can actually be downloaded
                    download_url = file_info['shared_link']['download_url']
                    client.request(:head, download_url)
                    hash['direct_links'] = true
                  rescue
                    # Ignore, this should mean we got a 403 and direct links aren't supported.
                  end
                  # Delete the temp file
                  access_token.delete("files/#{file_info['id']}")
                end
              end
            rescue
            end
          end
          hash
        end
      end

    end
  end
end

OmniAuth.config.add_camelization 'box_oauth2', 'BoxOAuth2'
