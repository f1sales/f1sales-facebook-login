require 'spec_helper'
require 'byebug'

describe 'F1SalesFacebookLogin' do
  describe 'GET /auth/:provider/callback' do
    let(:store_id) { Faker::Internet.domain_word }
    let(:return_to_url) { "https://#{store_id}.f1sales.org" }
    let(:auth_payload) { { 'token': token } }
    let(:token) { omniauth_payload[:credentials][:token] }
    let(:omniauth_payload) { Faker::Omniauth.facebook }

    context 'when provider is facebook' do
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
            get '/auth/facebook/callback', nil,
                { 'omniauth.auth' => omniauth_payload, 'omniauth.origin' => return_to_url }
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
            get '/auth/facebook/callback', nil,
                { 'omniauth.auth' => omniauth_payload, 'omniauth.origin' => return_to_url }
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

    context 'when provider is mercadolibre' do
      let(:omniauth_payload) do
        {
          provider: 'mercadolibre', uid: '12345678',
          info: payload_info,
          credentials: payload_credentials,
          extra: payload_extra
        }
      end
      let(:payload_info) do
        {
          email: 'leopoldo.becker@example.com',
          name: 'Leopoldo Becker',
          first_name: 'Leopoldo',
          last_name: 'Becker',
          image: 'https://via.placeholder.com/300x300.png',
          verified: false
        }
      end
      let(:payload_credentials) do
        {
          token: 'APP_USR-1234567890abcdefghij-123456-1234567890abcdefghij-12345678',
          expires_at: 1_690_923_127,
          expires: true
        }
      end
      let(:payload_extra) do
        {
          raw_info: {
            id: '6012052',
            name: 'Leopoldo Becker',
            first_name: 'Leopoldo',
            last_name: 'Becker',
            link: 'http://perfil.mercadolivre.com.br/lbecker',
            username: 'lbecker',
            location: {
              id: '761100967',
              name: 'Stantonburgh, Michigan'
            },
            gender: 'male',
            email: 'leopoldo.becker@example.com',
            timezone: -10,
            verified: false,
            updated_time: '2022-11-05T01:27:17-03:00'
          }
        }
      end

      context 'when store response is sucessful' do
        let(:redirect_url) { "https://#{store_id}.f1sales.org/dashboard/integrations~mercado_livre" }
        let!(:auth_store_request) do
          stub_request(:post, "#{return_to_url}/auth_mercado_livre")
            .with(
              body: auth_payload.to_json
            )
            .to_return(status: 200, body: {}.to_json, headers: {})
        end

        before do
          get '/auth/mercadolibre/callback', nil,
              { 'omniauth.auth' => omniauth_payload, 'omniauth.origin' => return_to_url }
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
