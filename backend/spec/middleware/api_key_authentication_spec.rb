require 'rails_helper'

RSpec.describe ApiKeyAuthentication do
  let(:app) { double('app') }
  let(:middleware) { ApiKeyAuthentication.new(app) }
  let(:tenant) { create(:tenant) }
  let(:machine) { ActsAsTenant.with_tenant(tenant) { create(:vending_machine, tenant: tenant) } }
  let(:api_key) { SecureRandom.hex(32) }
  
  before do
    ActsAsTenant.with_tenant(tenant) do
      machine.update!(api_key_digest: Rails.application.message_verifier('api_keys').generate(api_key))
    end
  end
  
  describe '#call' do
    context 'when request is not a machine API endpoint' do
      it 'passes through to the app without authentication' do
        env = {
          'REQUEST_METHOD' => 'GET',
          'PATH_INFO' => '/api/v1/admin/dashboard'
        }
        
        expect(app).to receive(:call).with(env)
        middleware.call(env)
      end
    end
    
    context 'when request is a machine API endpoint' do
      let(:env) do
        {
          'REQUEST_METHOD' => 'POST',
          'PATH_INFO' => '/api/v1/machines/sales',
          'HTTP_AUTHORIZATION' => "Bearer #{api_key}"
        }
      end
      
      it 'authenticates with valid API key and sets context' do
        expect(app).to receive(:call) do |passed_env|
          expect(passed_env['current_machine']).to eq(machine)
          expect(passed_env['current_tenant']).to eq(tenant)
        end
        
        middleware.call(env)
      end
      
      it 'returns 401 when API key is missing' do
        env.delete('HTTP_AUTHORIZATION')
        
        status, headers, body = middleware.call(env)
        
        expect(status).to eq(401)
        expect(headers['Content-Type']).to eq('application/json')
        expect(JSON.parse(body.first)['error']).to eq('API key required')
      end
      
      it 'returns 401 when API key is invalid' do
        env['HTTP_AUTHORIZATION'] = 'Bearer invalid_key'
        
        status, headers, body = middleware.call(env)
        
        expect(status).to eq(401)
        expect(headers['Content-Type']).to eq('application/json')
        expect(JSON.parse(body.first)['error']).to eq('Invalid API key')
      end
      
      it 'supports X-API-Key header' do
        env.delete('HTTP_AUTHORIZATION')
        env['HTTP_X_API_KEY'] = api_key
        
        expect(app).to receive(:call) do |passed_env|
          expect(passed_env['current_machine']).to eq(machine)
          expect(passed_env['current_tenant']).to eq(tenant)
        end
        
        middleware.call(env)
      end
    end
  end
end
