require "httparty"
require "nokogiri"

class WebScraperService
  class ScraperError < StandardError; end
  class FetchError < ScraperError; end
  class ParseError < ScraperError; end

  def initialize(url:, fields:)
    raise ScraperError, "URL is required" if url.blank?
    raise ScraperError, "Fields must be a Hash" unless fields.is_a?(Hash)

    @url = url
    @fields = fields
  end

  def call
    html = fetch_cached_html
    doc = parse_html(html)

    extract_fields(doc)
  end

  private

  def fetch_cached_html
    cache_key = "web_scraper:html:#{@url}"

    Rails.cache.fetch(cache_key, expires_in: 6.hours) do
      response = HTTParty.get(@url, timeout: 10)

      unless response.success?
        raise FetchError, "Failed to fetch page: HTTP #{response.code}"
      end

      response.body
    end
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    raise FetchError, "Timeout while fetching URL: #{e.message}"
  rescue HTTParty::Error => e
    raise FetchError, "HTTP error: #{e.message}"
  end

  def parse_html(html)
    Nokogiri::HTML(html)
  rescue => e
    raise ParseError, "Failed to parse HTML: #{e.message}"
  end

  def extract_fields(doc)
    result = {}

    @fields.each do |key, value|
      if (key == "meta" || key == :meta) && value.is_a?(Array)
        result["meta"] = extract_meta_tags(doc, value)
      elsif value.is_a?(String)
        result[key] = doc.css(value)&.first&.text&.strip
      else
        raise ScraperError, "Invalid selector for key '#{key}': must be a CSS selector string"
      end
    end

    result
  end

  def extract_meta_tags(doc, tags)
    tags.each_with_object({}) do |tag, meta_hash|
      meta_element = doc.at("meta[name='#{tag}']") || doc.at("meta[property='#{tag}']")
      meta_hash[tag] = meta_element&.[]("content")
    end
  end
end
