require 'hashie'
require 'httmultiparty'
require 'uri'

require 'boxnet/array_response_wrapper'
require 'boxnet/client'
require 'boxnet/hash_response_wrapper'
require 'boxnet/response_error'
require 'boxnet/version'

module BoxNet

  def new(options={})
    Client.new(options)
  end
  module_function :new

  def method_missing(method_name, *args, &block)
    return super unless respond_to_missing?(method_name)
    Client.send(method_name, *args, &block)
  end
  module_function :method_missing

  def respond_to_missing?(method_name, include_private=false)
    Client.respond_to?(method_name, include_private)
  end
  module_function :respond_to_missing?

end

BoxNet = BoxNet
