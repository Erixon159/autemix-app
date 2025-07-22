require 'rails_helper'

RSpec.describe TenantResolver, type: :middleware do
  let(:app) { double('app') }
  let(:middleware) { TenantResolver.new(app) }
  let!(:active_tenant) { create(:tenant, subdomain: 'testcompany', active: true) }
  let!(:inactive_tenant) { create(:tenant, subdomain: 'inactive', active: false) }
  
  describe '#call' do
    context 'with valid subdomain in host' do
      let(:env) do
        {
          'HTTP_HOST' => 'testcompany.autemix.com',
          'REQUEST_PATH' => '/api/test',
          'REQUEST_METHOD' => 'GET'
        }
      end
      
      it 'sets the current tenant and calls the app' do
        expect(app).to receive(:call).with(env).and_return([200, {}, ['OK']])
        
        response = middleware.call(env)
        
        expect(response).to eq([200, {}, ['OK']])
      end
      
      it 'cleans up the global request environment variable' do
        allow(app).to receive(:call).and_return([200, {}, ['OK']])
        
        middleware.call(env)
        
        expect($request_env).to be_nil
      end
    end
    
    context 'with valid subdomain in localhost (development)' do
      let(:env) do
        {
          'HTTP_HOST' => 'testcompany.localhost:3001',
          'REQUEST_PATH' => '/api/test',
          'REQUEST_METHOD' => 'GET'
        }
      end
      
      it 'resolves tenant from localhost subdomain' do
        expect(app).to receive(:call).with(env).and_return([200, {}, ['OK']])
        
        response = middleware.call(env)
        
        expect(response).to eq([200, {}, ['OK']])
      end
    end
    
    context 'with valid tenant header' do
      let(:env) do
        {
          'HTTP_HOST' => 'api.autemix.com',
          'HTTP_X_TENANT_SUBDOMAIN' => 'testcompany',
          'REQUEST_PATH' => '/api/test',
          'REQUEST_METHOD' => 'GET'
        }
      end
      
      it 'resolves tenant from header' do
        expect(app).to receive(:call).with(env).and_return([200, {}, ['OK']])
        
        response = middleware.call(env)
        
        expect(response).to eq([200, {}, ['OK']])
      end
    end
    
    context 'with inactive tenant' do
      let(:env) do
        {
          'HTTP_HOST' => 'inactive.autemix.com',
          'REQUEST_PATH' => '/api/test',
          'REQUEST_METHOD' => 'GET'
        }
      end
      
      it 'returns 404 for inactive tenant' do
        response = middleware.call(env)
        
        expect(response[0]).to eq(404)
        expect(response[1]['Content-Type']).to eq('application/json')
        
        body = JSON.parse(response[2].first)
        expect(body['error']).to eq('Tenant not found')
      end
    end
    
    context 'with non-existent tenant' do
      let(:env) do
        {
          'HTTP_HOST' => 'nonexistent.autemix.com',
          'REQUEST_PATH' => '/api/test',
          'REQUEST_METHOD' => 'GET'
        }
      end
      
      it 'returns 404 for non-existent tenant' do
        response = middleware.call(env)
        
        expect(response[0]).to eq(404)
        expect(response[1]['Content-Type']).to eq('application/json')
        
        body = JSON.parse(response[2].first)
        expect(body['error']).to eq('Tenant not found')
      end
    end
    
    context 'with no subdomain' do
      let(:env) do
        {
          'HTTP_HOST' => 'autemix.com',
          'REQUEST_PATH' => '/api/test',
          'REQUEST_METHOD' => 'GET'
        }
      end
      
      it 'returns 404 when no subdomain is present' do
        response = middleware.call(env)
        
        expect(response[0]).to eq(404)
      end
    end
  end
  
  describe '#extract_subdomain' do
    it 'extracts subdomain from production domain' do
      subdomain = middleware.send(:extract_subdomain, 'company.autemix.com')
      expect(subdomain).to eq('company')
    end
    
    it 'extracts subdomain from localhost' do
      subdomain = middleware.send(:extract_subdomain, 'company.localhost')
      expect(subdomain).to eq('company')
    end
    
    it 'extracts subdomain from localhost with port' do
      subdomain = middleware.send(:extract_subdomain, 'company.localhost:3001')
      expect(subdomain).to eq('company')
    end
    
    it 'returns nil for domain without subdomain in production' do
      # In production mode, we need at least 3 parts (subdomain.domain.tld)
      # For 2 parts (domain.tld), there's no subdomain
      allow(Rails.env).to receive(:development?).and_return(false)
      subdomain = middleware.send(:extract_subdomain, 'autemix.com')
      expect(subdomain).to be_nil
    end
    
    it 'returns nil for localhost without subdomain' do
      subdomain = middleware.send(:extract_subdomain, 'localhost:3001')
      expect(subdomain).to be_nil
    end
  end
end