require 'rails_helper'

RSpec.describe "ShortLinks API", type: :request do
  # Helper to parse JSON responses
  def json_response
    JSON.parse(response.body)
  end

  describe "POST /encode" do
    let(:valid_url) { "https://www.codesubmit.io/library/react" }

    context "with valid parameters" do
      before { post "/encode", params: { url: valid_url } }

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the shortened URL" do
        expect(json_response["short_url"]).to include(request.base_url)
      end

      it "returns the original URL in the response" do
        expect(json_response["original_url"]).to eq(valid_url)
      end
    end

    context "with invalid parameters" do
      it "returns error if URL is missing" do
        post "/encode", params: { url: "" }
        # Change :unprocessable_entity to 422
        expect(response).to have_http_status(422) 
        expect(json_response["error"]).to be_present
      end

      it "returns error if URL is malformed" do
        post "/encode", params: { url: "not-a-http-url" }
        # Change :unprocessable_entity to 422
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "POST /decode" do
    let!(:link) { ShortLink.create!(original_url: "https://www.google.com") }
    # Construct the full short URL that the client would send back
    let(:short_url) { "http://www.example.com/#{link.short_code}" }

    context "with valid short URL" do
      before { post "/decode", params: { url: short_url } }

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the original URL" do
        expect(json_response["original_url"]).to eq("https://www.google.com")
      end
    end

    context "with non-existent URL" do
      it "returns 404 not found" do
        post "/decode", params: { url: "http://www.example.com/NONEXISTENT" }
        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to eq("URL not found")
      end
    end
  end
end