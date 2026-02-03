class ShortLinksController < ApplicationController
  # POST /encode
  # Params: { "url": "https://google.com" }
  def encode
    original = params[:url]
    return render_error("URL is required") if original.blank?

    # Check if we already have this URL to avoid duplicates (Optimization)
    link = ShortLink.find_or_create_by(original_url: original)

    if link.persisted?
      render json: { short_url: construct_url(link.short_code) }, status: :ok
    else
      render_error(link.errors.full_messages.join(", "))
    end
  end

  # POST /decode
  # Params: { "url": "http://domain/GeAi9K" }
  def decode
    short_url = params[:url]
    return render_error("URL is required") if short_url.blank?

    # Extract the code from the URL (e.g., "GeAi9K")
    code = short_url.split('/').last
    link = ShortLink.find_by(short_code: code)

    if link
      render json: { original_url: link.original_url }, status: :ok
    else
      render_error("URL not found", :not_found)
    end
  end

  private

  def construct_url(code)
    "#{request.base_url}/#{code}"
  end

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end
end