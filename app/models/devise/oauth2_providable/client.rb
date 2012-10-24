class Devise::Oauth2Providable::Client < ActiveRecord::Base
  has_many :access_tokens
  has_many :refresh_tokens
  has_many :authorization_codes
  has_many :available_scopes

  before_validation :init_identifier, :on => :create, :unless => :identifier?
  before_validation :init_secret, :on => :create, :unless => :secret?
  validates :website, :secret, :presence => true
  validates :name, :presence => true, :uniqueness => true
  validates :identifier, :presence => true, :uniqueness => true

  attr_accessible :name, :website, :redirect_uri

  scope :by_request, ->(request) {
    token = nil
    if request.env["HTTP_AUTHORIZATION"].present? && request.env["HTTP_AUTHORIZATION"].match(/^Bearer \w+/)
      token = request.env["HTTP_AUTHORIZATION"].gsub /^Bearer /, ''
    elsif request.params["access_token"].present? && request.params["access_token"].match(/\w+/)
      token = request.params["access_token"]
    end
    joins(:access_tokens).
      where(oauth2_access_tokens: { token: token })
  }

  def new_client_response
    {
      :client_id => identifier,
      :client_secret => secret
    }
  end

  private

  def init_identifier
    self.identifier = Devise::Oauth2Providable.random_id
  end

  def init_secret
    self.secret = Devise::Oauth2Providable.random_id
  end

end
