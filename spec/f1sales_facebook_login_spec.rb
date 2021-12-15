require 'spec_helper'

describe 'F1SalesFacebookLogin' do

  describe 'GET /auth/faceook/callback' do
    let(:store_id) { Faker::Hipster.word }
    let(:return_to_url) { "https://#{store_id}.f1sales.org" }
    let(:omniauth_payload) { Faker::Omniauth.facebook }
    let(:auth_payload) { { 'token': token } }
    let(:token) { omniauth_payload[:credentials][:token] }

    context 'when token is given' do
      context 'when store response is not sucessful' do
        let(:redirect_url) { "https://#{store_id}.f1sales.org/auth/facebook/failure" }

        let!(:auth_store_request) do
          stub_request(:post, "#{return_to_url}/auth/facebook/token")
            .with(
              body: auth_payload.to_json
            )
            .to_return(status: 401, body: {}.to_json, headers: {})
        end
        before do
          get '/auth/facebook/callback', nil, { 'omniauth.auth' => omniauth_payload, 'omniauth.origin' => return_to_url }
        end

        it 'post to origin with givem token' do
          expect(auth_store_request).to have_been_requested
        end

        it 'redirect to not authorized' do
          expect(last_response).to be_redirect
          follow_redirect!
          expect(last_request.url).to eq(redirect_url)
        end
      end

      context 'when store response is sucessful' do
        let(:redirect_url) { "https://#{store_id}.f1sales.org/dashboard/integrations~facebook_page" }

        let!(:auth_store_request) do
          stub_request(:post, "#{return_to_url}/auth/facebook/token")
            .with(
              body: auth_payload.to_json
            )
            .to_return(status: 200, body: {}.to_json, headers: {})
        end
        before do
          get '/auth/facebook/callback', nil, { 'omniauth.auth' => omniauth_payload, 'omniauth.origin' => return_to_url }
        end

        it 'post to origin with given token' do
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
end
