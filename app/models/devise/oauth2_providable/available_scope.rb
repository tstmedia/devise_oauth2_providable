module Devise
  module Oauth2Providable
    class AvailableScope < ActiveRecord::Base
      include EnumeratedField
      belongs_to :client

      attr_accessible :scope_name

      delegate :name, :description,
        to: :scope

      enum_field :scope_name,
        Scope.names_for_enum

      def scope
        Scope[scope_name]
      end
    end
  end
end
