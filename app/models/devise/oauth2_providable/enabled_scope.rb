class Devise::Oauth2Providable::EnabledScope < ActiveRecord::Base
  belongs_to :available_scope
  belongs_to :user

  delegate :client, :name, :scope,
    to: :available_scope
end
