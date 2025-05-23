class ForecastsController < ApplicationController
  def index
    return unless params[:address].present?

    begin
      @forecast_service = ForecastService.new(params[:address])
      @forecast = @forecast_service.fetch_forecast
      @from_cache = @forecast_service.from_cache?
    rescue => e
      @error = e.message
    end
  end
end
