
# ShortLink API
A robust, scalable URL shortening service built with Ruby on Rails API. This service provides a RESTful interface to encode URLs into short codes and decode them back to their original state.

## 🚀 Getting Started
Prerequisites
- Ruby 3.x
- Rails 7.x
- SQLite3 (Development/Test) / PostgreSQL (Production recommended)

## Live Demo 
You can test the live deployment at: `https://shortlink-api-pnrk.onrender.com`

**Note: the demo is on a free tier, so it might take some time to spin up whenever you try it** 

### 1. Encode a URL
Converts a long URL into a shortened link.

* **Endpoint:** `POST /encode`
* **Content-Type:** `application/json`

**Request:**
```
curl -X POST https://shortlink-api-pnrk.onrender.com/encode \
     -H "Content-Type: application/json" \
     -d '{"url": "https://codesubmit.io/library/react"}'
```

**Response (200 OK):**
```
JSON

{
  "short_url": "https://shortlink-api-pnrk.onrender.com/1b",
  "original_url": "https://codesubmit.io/library/react"
}
```

### 2. Decode a URL
Retrieves the original URL from a shortened link.

* **Endpoint:** POST /decode

* **Content-Type:** `application/json`

**Request:**

### Replace '1b' with the actual code you received from the encode step
```
curl -X POST https://shortlink-api-pnrk.onrender.com/decode \
     -H "Content-Type: application/json" \
     -d '{"url": "https://shortlink-api-pnrk.onrender.com/1b"}'
```

**Response (200 OK):**

```
JSON

{
  "original_url": "https://codesubmit.io/library/react"
}
```

### 3. Error Handling
Test invalid inputs to verify validation logic.

**Request:**

```
curl -X POST https://shortlink-api-pnrk.onrender.com/encode \
     -H "Content-Type: application/json" \
     -d '{"url": "not-a-valid-url"}'
```

**Response (422 Unprocessable Entity):**
```
JSON

{
  "error": "Original url is invalid"
}
```

## Installation
Clone the repository:

```
git clone https://github.com/yourusername/shortlink.git

cd shortlink

```
Install dependencies:

```
bundle install
```
Setup the database:

```
rails db:migrate
```
Run the server:

```
rails s
```
## Running Tests
The suite includes unit tests (Models) and integration tests (Requests) using RSpec.

```
bundle exec rspec
```
## 📖 API Documentation
### Encode a URL
 Converts a long URL into a shortened link.

Endpoint: POST /encode

Content-Type: application/json
```
Request:

JSON

{
  "url": "https://codesubmit.io/library/react"
}
```
```
Response (200 OK):

JSON

{
  "short_url": "http://localhost:3000/1b",
  "original_url": "https://codesubmit.io/library/react"
}
```
### Decode a URL
Retrieves the original URL from a shortened link.

Endpoint: POST /decode

Content-Type: application/json
```
Request:

JSON

{
  "url": "http://localhost:3000/1b"
}
```
```
Response (200 OK):

JSON

{
  "original_url": "https://codesubmit.io/library/react"
}
```
### 🏗 Architecture & Design Decisions
**The Algorithm: Base62 Encoding** 

Instead of generating random strings (which requires checking the DB for collisions and retrying), this system uses a **Bijective Function**  based on Base62 encoding.

* Mechanism: The database's auto-incrementing Integer ID is converted into a base-62 string (`[a-z, A-Z, 0-9]`).

* **Example:** ID `100` -> `1C`.

* **Why?** This guarantees **mathematical uniqueness**. Because every Database ID is unique, every short code is automatically unique. There are **zero collisions** by design.

**Separation of Concerns**

* **Service Layer** (`IdEncoder`): The logic for converting Integers to/from Base62 strings is isolated in a pure Ruby module. It creates no side effects and is easily testable.

* **Fat Model, Skinny Controller:** The Model handles the data integrity and JSON formatting (`to_json_response`), keeping the Controller focused strictly on HTTP request handling.

**📈 Scalability Strategy**

Current implementation handles thousands of requests per second. However, to scale to millions of users, the following roadmap is proposed:

* **Phase 1: Database Optimization & Caching**
    * **Indexing**: The short_code column is indexed. Lookup time is O(log N).

    * **Caching (Redis):** URL mappings are immutable (a code always points to the same URL). We can place a Redis cache in front of the /decode endpoint. This would handle 90-95% of read traffic without hitting the primary database.

* **Phase 2: Horizontal Scaling (Read Replicas)**
    * Shortener services are typically Read-Heavy (100:1 read-to-write ratio).

    * We can deploy multiple Read Replicas of the PostgreSQL database. The application will route POST /decode requests to replicas and POST /encode to the primary writer.

* **Phase 3: Sharding & Distributed IDs (The "Twitter Snowflake" Approach)**
    * **The Limit:** Eventually, a single database cannot handle the write volume of new links.

    * **The Solution:** We move away from Auto-Incrementing IDs (which lock a single DB table) to a distributed ID generator (like Twitter Snowflake or UUIDs).

    * **Sharding:** We can then shard the database based on the ID range. Since the ID generation is distributed, we can write to multiple database nodes simultaneously without collision.

### 🛡 Security & Attack Vectors
1. Enumeration Attacks
    * Risk: Because IDs are sequential (1, 2, 3...), an attacker could simply increment the code (a, b, c) to scrape all stored URLs.

    * Mitigation: * ID Obfuscation: Use a Feistel Cipher to permute the ID before encoding. This makes sequential IDs appear random (e.g., 1 -> X9, 2 -> b4) while maintaining uniqueness.

    * Rate Limiting: Implement Rack::Attack to throttle requests from a single IP.

2. Phishing & Malware Distribution
    * Risk: Attackers use shorteners to mask malicious URLs (e.g., bit.ly/prize -> malware-site.com).

    * Mitigation: * Blacklisting: Validate input URLs against a domain blacklist.

    * Async Scanning: Implement a background job (Sidekiq) that scans new URLs against Google Safe Browsing API.

3. Denial of Service (DoS)
    * Risk: A bot floods the /encode endpoint, filling the database with junk data.

    * Mitigation: * Rate Limiting: Limit users to X links per minute.

    * Input Validation: Ensure URL validity and length limits (max 2048 chars) before processing.

### 🧪 Testing Strategy
* Unit Tests: Verify the `IdEncoder` math and Model validations strictly.

* Request Tests: Verify the API contract (Inputs/Outputs) and HTTP status codes (404 vs 422 vs 200).

* Edge Cases: Tests specifically cover invalid URL formats, empty payloads, and non-existent codes.
