class ForecastService
  include HTTParty
  base_uri 'https://api.openweathermap.org/data/2.5'

  def initialize(address)
    @address = address
    @location = Geocoder.search(address).first
    raise ArgumentError, 'Invalid address' unless @location
    @zip_code = @location.postal_code
    @coordinates = @location.coordinates
  end

  def fetch_forecast
    Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      response = self.class.get('/weather', query: {
        lat: @coordinates[0],
        lon: @coordinates[1],
        appid: ENV['OPENWEATHER_API_KEY'],
        units: 'metric'
      })
      raise "API error: #{response.code}" unless response.success?
      response.parsed_response
    end
  end

  def from_cache?
    Rails.cache.exist?(cache_key)
  end

  private

  def cache_key
    "forecast:#{@zip_code}"
  end


end