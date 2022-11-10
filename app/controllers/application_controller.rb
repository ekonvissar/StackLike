class ApplicationController < ActionController::Base
    def index
        @userparams = params[:username]
    end
end
