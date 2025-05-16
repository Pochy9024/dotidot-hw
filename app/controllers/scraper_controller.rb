class ScraperController < ApplicationController
  def data
    url = scrapping_params[:url]
    fields = selector_fields

    return render json: { error: "URL is required" }, status: :unprocessable_entity if url.blank?
    return render json: { error: "Fields must be a Hash" }, status: :unprocessable_entity unless fields.is_a?(Hash)

    service = WebScraperService.new(url: url, fields: fields)
    render json: service.call
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def selector_fields
    if scrapping_params[:fields].present?
      scrapping_params[:fields].to_h
    else
      nil
    end
  end

  def scrapping_params
    params.permit(:url, fields: {})
  end
end
