# spec/services/forecast_service_spec.rb
require 'rails_helper'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.describe ForecastService do
  let(:address) { "Hyderabad, India" }

  before do
    # Mock Geocoder to return coordinates for Hyderabad
    allow(Geocoder).to receive(:search).with(address).and_return([
      double("Geocoder::Result",
        postal_code: "500001",
        coordinates: [17.385044, 78.486671]
      )
    ])

    # Mock OpenWeather API response
    stub_request(:get, /api.openweathermap.org/).to_return(
      status: 200,
      body: {
        main: { temp: 31.0, temp_min: 27.0, temp_max: 35.0 },
        weather: [{ description: "clear sky" }]
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  it 'fetches forecast data for Hyderabad and caches it' do
    service = ForecastService.new(address)
    data = service.fetch_forecast

    expect(data['main']['temp']).to eq(31.0)
    expect(data['main']['temp_min']).to eq(27.0)
    expect(data['main']['temp_max']).to eq(35.0)
    expect(data['weather'][0]['description']).to eq("clear sky")
    expect(service.from_cache?).to be true
  end

  it 'raises error for an invalid address' do
    allow(Geocoder).to receive(:search).and_return([])
    expect { ForecastService.new("Invalid Address") }.to raise_error(ArgumentError)
  end
end