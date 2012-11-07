module Devise
  module Oauth2Providable
    class AuthorizationsController < ApplicationController
      before_filter :authenticate_user!

      rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
        @error = e
        respond_to do |f|
          f.json { render :json => { metadata: {}, error: e, result: {} }.to_json }
          f.xml { render :xml => { metadata: {}, error: e, result: {} }.to_xml }
          f.html { render :error, :status => e.status }
        end
      end

      def new
        respond *authorize_endpoint.call(request.env)
      end

      def create
        respond *authorize_endpoint(:allow_approval).call(request.env)
      end

      private

      def respond(status, header, response)
        ["WWW-Authenticate"].each do |key|
          headers[key] = header[key] if header[key].present?
        end
        if response.redirect?
          redirect_to header['Location']
        else
          render :new
        end
      end

      def authorize_endpoint(allow_approval = false)
        Rack::OAuth2::Server::Authorize.new do |req, res|
          @client = Client.find_by_identifier(req.client_id) || req.bad_request!

          res.redirect_uri = @redirect_uri = @client.redirect_uri #= req.verify_redirect_uri!(@client.redirect_uri, :allow_partial_match)
          if allow_approval
            if params[:approve].present?
              case req.response_type
              when :code
                #Devise::Oauth2Providable::EnabledScope.create_or_change current_user, @client, (req.params["scope"] || {})
                authorization_code = current_user.authorization_codes.create!(:client => @client)
                res.code = authorization_code.token
              when :token
                access_token = current_user.access_tokens.create!(:client => @client).token
                bearer_token = Rack::OAuth2::AccessToken::Bearer.new(:access_token => access_token)
                res.access_token = bearer_token
                res.uid = current_user.id
              end
              res.approve!
            else
              req.access_denied!
            end
          else
            #TODO What if we end up no scopes or something?
            #@scopes = @client.available_scopes.where({
              #scope_name: Scope.find_from_comma_delimiter(req.scope.first).map(&:name)
            #})
            @response_type = req.response_type
          end
        end
      end
    end
  end
end
