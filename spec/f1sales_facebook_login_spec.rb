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
          provider: 'mercadolibre',
          uid: '12345678',
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
          refresh_token: 'TG-1234567890abcefghij-1234567890',
          expires_at: 1_690_923_127,
          expires: true
        }
      end

      let(:payload_extra) do
        {
          raw_info: {
            id: '12345678',
            site_id: 'MLB',
            first_name: 'Leopoldo',
            last_name: 'Becker',
            email: 'leopoldo.becker@example.com',
            gender: 'M',
            nickname: 'LBECKER',
            permalink: 'http://perfil.mercadolivre.com.br/lbecker',
            identification: {
              type: 'CPF',
              number: '12345678901'
            },
            phone: {
              number: '11912345678'
            },
            address: {
              address: 'Rua dos bobos 0',
              zip_code: '0000000',
              city: 'Algum lugar',
              state: 'BO-BO'
            }
          }
        }
      end

      let(:auth_payload) do
        {
          user_id: omniauth_payload[:uid],
          access_token: token,
          refresh_token: payload_credentials[:refresh_token]
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

      context 'when store response is 302' do
        let(:redirect_url) { "https://#{store_id}.f1sales.org/dashboard/integrations~mercado_livre" }

        let!(:auth_store_request) do
          stub_request(:post, "#{return_to_url}/auth_mercado_livre")
            .with(
              body: auth_payload.to_json
            )
            .to_return(status: 302, body: {}.to_json, headers: {})
        end

        before do
          get '/auth/mercadolibre/callback', nil,
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

      context 'when store response is not sucessful' do
        let(:redirect_url) { "https://#{store_id}.f1sales.org/auth/mercado_livre/failure" }

        let!(:auth_store_request) do
          stub_request(:post, "#{return_to_url}/auth_mercado_livre")
            .with(
              body: auth_payload.to_json
            )
            .to_return(status: 500, body: {}.to_json, headers: {})
        end

        before do
          get '/auth/mercadolibre/callback', nil,
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
    end
  end
end
