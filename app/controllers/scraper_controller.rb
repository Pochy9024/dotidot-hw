class ScraperController < ApplicationController
  def data
    data = WebScraperService.call(url: scrapping_params[:url], fields: scrapping_params[:fields])

    if data[:error]
      render json: { error: data[:error] }, status: :unprocessable_entity
    else
      render json: data, status: :ok
    end
  end

  private

  def scrapping_params
    params.permit(:url, fields: {})
  end
end
