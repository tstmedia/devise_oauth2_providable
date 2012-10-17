require 'spec_helper'

describe Devise::Oauth2Providable::ClientsController do
  describe 'POST #create' do
    context 'with valid params' do
      let(:client_id) { "123" }
      let(:client_secret) { "abc" }
      let(:expected) { { client_id: client_id, client_secret: client_secret }.to_json }
      before do
        Devise::Oauth2Providable.stub(:random_id).and_return(client_id, client_secret)
        post :create,
          client: {
            name: "test",
            website: "http://example.com",
            redirect_uri: "http://example.com/redirect"
        },
        use_route: 'devise_oauth2_providable'
      end
      context 'with new client' do
        it { should respond_with :ok }
        it { should respond_with_content_type :json }
        it { response.body.should == expected }
      end

      context 'with existing client' do
        let(:client) do
          c = Devise::Oauth2Providable::Client.new
          c.stub(client_id: client_id, client_secret: client_secret, new_record?: false)
          c
        end
        before do
          Devise::Oauth2Providable::Client.stub_chain(:where, :first).and_return client
        end
        it { should respond_with :ok }
        it { should respond_with_content_type :json }
        it { response.body.should == expected }
      end
    end

    context 'create with invlaid params' do
      let(:expected) { { website: ["can't be blank"], name: ["can't be blank"] }.to_json }
      before do
        post :create,
        use_route: 'devise_oauth2_providable'
      end
      it { should respond_with :bad_request }
      it { should respond_with_content_type :json }
      it { response.body.should == expected }
    end
  end
end
