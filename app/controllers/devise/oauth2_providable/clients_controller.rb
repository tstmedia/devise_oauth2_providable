module Devise
  module Oauth2Providable
    class ClientsController < ApplicationController
      # TODO Ensure we lock this to internal use
      # Will primarily be used for Elmer gem users to create a client easily
      def create
        client = Client.where(params[:client]).first || Client.new(params[:client])
        if !client.new_record? or client.save
          render :json => client.new_client_response
        else
          render :status => :bad_request, :json => client.errors
        end
      end
    end
  end
end
