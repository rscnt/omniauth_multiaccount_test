class HomeController < ApplicationController
  def index
    @provider = params[:provider]
    @current_user
  end
end
