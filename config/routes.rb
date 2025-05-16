Rails.application.routes.draw do
  # Scraper route
  get "/data", to: "scraper#data"
end
