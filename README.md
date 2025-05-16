# Web Scraper API

A simple Rails-based web scraper that extracts data from a URL using CSS selectors and meta tag names.


## Setup Instructions

### 1. Clone the repo

```bash
git clone https://github.com/Pochy9024/dotidot-hw.git
cd web-scraper-api
```

### 2. Install dependencies
```bash
bundle install
```

### 3. Start the Rails server
```bash
rails s
```
Server will run at: `http://localhost:3000`

## API Usage
### Endpoint
```bash
GET /data
```

### Request Parameters (JSON)
Example 1: Using CSS selectors
```json
{
  "url": "https://example.com",
  "fields": {
    "price": ".price-box__price",
    "rating_value": ".ratingValue"
  }
}
```

Example 2: Using meta tag names
```json
{
  "url": "https://example.com",
  "fields": {
    "meta": ["keywords", "twitter:image"]
  }
}
```

### Example Response
```json
{
  "price": "18290,-",
  "rating_value": "4,9",
  "meta": {
    "keywords": "example, test, data",
    "twitter:image": "https://cdn.example.com/image.jpg"
  }
}
```

## Running Tests
```bash
bundle exec rspec
```
