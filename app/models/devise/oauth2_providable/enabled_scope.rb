class Devise::Oauth2Providable::EnabledScope < ActiveRecord::Base
  belongs_to :available_scope
  belongs_to :user

  delegate :client, :name, :scope,
    to: :available_scope

  def self.create_or_change(user, client, scope_params)
    available_scopes = client.available_scopes.
      inject({}) { |h,k| h[k.name.to_s] = k.id; h }
    scopes = scope_params.select { |k,v| available_scopes[k.to_s] && v.to_s == "1" }.keys
    already_have = Devise::Oauth2Providable::EnabledScope.
      joins(:available_scope).
      where(
        user_id: user.id,
        oauth2_available_scopes: {
          scope_name: scopes
        }
      ).collect(&:name)
    Devise::Oauth2Providable::EnabledScope.joins(:available_scope).where(
      user_id: user.id,
      oauth2_available_scopes: {
        client_id: client.id
      }
    ).where("oauth2_available_scopes.scope_name NOT IN (?)", scopes).destroy_all
    (scopes - already_have).each do |scope_name|
      enabled = new
      enabled.user_id = user.id
      enabled.available_scope_id = available_scopes[scope_name]
      enabled.save
    end
  end
end
