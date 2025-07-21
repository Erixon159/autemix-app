require 'rails_helper'

RSpec.describe HealthController, type: :controller do
  describe 'GET #show' do
    it 'returns a successful response' do
      get :show
      expect(response).to have_http_status(:ok)
    end

    it 'returns JSON with health status' do
      get :show
      json_response = JSON.parse(response.body)
      
      expect(json_response).to include(
        'status' => 'ok',
        'version' => '1.0.0-dev'
      )
      expect(json_response).to have_key('services')
    end

    it 'includes database status' do
      get :show
      json_response = JSON.parse(response.body)
      
      expect(json_response['services']).to include('database')
      expect(json_response['services']['database']).to eq('connected')
    end

    it 'includes redis status' do
      get :show
      json_response = JSON.parse(response.body)
      
      expect(json_response['services']).to include('redis')
      expect(json_response['services']['redis']).to eq('connected')
    end

    it 'includes sidekiq status' do
      get :show
      json_response = JSON.parse(response.body)
      
      expect(json_response['services']).to include('sidekiq')
      expect(json_response['services']['sidekiq']).to include('status')
    end

    it 'includes timestamp' do
      get :show
      json_response = JSON.parse(response.body)
      
      expect(json_response).to include('timestamp')
      expect(json_response['timestamp']).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
    end
  end
end
