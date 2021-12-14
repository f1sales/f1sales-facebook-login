require 'spec_helper'

describe 'F1SalesFacebookLogin' do
  let(:store_id) { Faker::Hipster.word }

  describe 'GET /auth/faceook/callback' do
    let(:return_to_url) { "https://#{store_id}.f1sales.org/auth/facebook/callback" }
    let(:omniauth_payload) { Faker::Omniauth.facebook }
    let(:auth_payload) { { 'token': token } }
    let(:token) { omniauth_payload[:credentials][:token] }

    context 'when token are not given' do
      xit 'it post to origin error' do
        # TODO...
      end
    end

    context 'when token is given' do
      let(:integration_id_created) { Faker::Crypto.md5 }
      let(:redirect_url) { "https://#{store_id}.f1sales.org/integrations~facebook/#{integration_id_created}" }

      let!(:auth_store_request) do
        stub_request(:post, return_to_url)
          .with(
            body: auth_payload.to_json
          )
          .to_return(status: 200, body: { 'redirect' => redirect_url }.to_json, headers: {})
      end
      before do
        get '/auth/facebook/callback', nil, { 'omniauth.auth' => omniauth_payload, 'omniauth.origin' => return_to_url }
      end

      it 'post to origin with givem token' do
        expect(auth_store_request).to have_been_requested
      end

      it 'redirect to created integration' do
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.url).to eq(redirect_url)
      end
    end
  end
end
