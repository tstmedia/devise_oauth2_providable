module Devise
  module Oauth2Providable
    module Generators
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path("../../../templates", __FILE__)
        desc "Creates a scopes config yml, installs route mount and installs migrations"

        # TODO: if only user_service_url set then run through the client generation
        def copy_config
          template "scopes.yml", "config/scopes.yml"
        end

        def mount_routes
          route "mount Devise::Oauth2Providable::Engine => '/oauth'"
        end

        def install_migrations
          rake "devise_oauth2_providable:install:migrations"
        end
      end
    end
  end
end
