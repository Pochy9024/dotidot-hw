# frozen_string_literal: true

require "nokogiri"
require "open-uri"

class WebScraperService
  attr_accessor :url, :fields

  class << self
    def call(**kwargs)
      new(**kwargs).call
    end
  end

  def initialize(url:, fields: {})
    @url = url
    @fields = fields
  end

  def call
    response = Rails.cache.fetch("page:#{url}", expires_in: 12.hours) do
      HTTParty.get(url).body
    end
    doc = Nokogiri::HTML(response)

    result = {}

    fields.each do |key, selector|
      next if key == "meta"
      result[key] = doc.css(selector)&.first&.text&.strip
      byebug
    end

    if fields["meta"]
      result["meta"] = {}
      fields["meta"].each do |meta_name|
        tag = doc.at("meta[name='#{meta_name}']") || doc.at("meta[property='#{meta_name}']")
        result["meta"][meta_name] = tag&.[]("content")
      end
    end

    result
  rescue => e
    { error: e.message }
  end
end
