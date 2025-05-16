require 'rails_helper'

RSpec.describe "ScraperController", type: :request do
  let(:url) { "https://example.com" }
  let(:html_response) { file_fixture("example_com.html").read }

  before do
    stub_request(:get, url).to_return(status: 200, body: html_response)
  end

  describe "GET /data" do
    context "with valid CSS selectors" do
      it "returns extracted values" do
        get "/data", params: {
          url: url,
          fields: {
            price: ".price-box__price",
            rating_count: ".ratingCount",
            rating_value: ".ratingValue"
          }
        }

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        p data
        expect(data["price"]).to eq("18290,-")
        expect(data["rating_count"]).to eq("7 hodnocení")
        expect(data["rating_value"]).to eq("4,9")
      end
    end

    context "with valid meta tags" do
      it "returns meta values" do
        get "/data", params: {
          url: url,
          fields: {
            meta: [ "keywords", "twitter:image" ]
          }
        }

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)

        expect(data["meta"]["keywords"]).to eq("example, test, data")
        expect(data["meta"]["twitter:image"]).to eq("https://cdn.example.com/image.jpg")
      end
    end

    context "when url is missing" do
      it "returns error" do
        get "/data", params: { fields: { title: ".header" } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("URL is required")
      end
    end

    context "when fields are missing" do
      it "returns error" do
        get "/data", params: { url: url }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Fields must be a Hash")
      end
    end

    context "when field value is not a string or array" do
      it "returns error for invalid selector" do
        get "/data", params: {
          url: url,
          fields: { price: [ 123 ] }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to match(/Invalid selector for key/)
      end
    end

    context "when external site returns HTTP error" do
      before do
        stub_request(:get, "https://badsite.com").to_return(status: 500)
      end

      it "returns fetch error" do
        get "/data", params: {
          url: "https://badsite.com",
          fields: { price: ".price" }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to match(/Failed to fetch page/)
      end
    end

    context "when timeout occurs" do
      before do
        stub_request(:get, "https://timeout.com").to_timeout
      end

      it "returns timeout error" do
        get "/data", params: {
          url: "https://timeout.com",
          fields: { price: ".price" }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to match(/Timeout while fetching URL/)
      end
    end
  end
end
