class ShortLinksController < ApplicationController
  # POST /encode
  def encode
    original = params[:url]
    return render_error("URL is required") if original.blank?

    link = ShortLink.find_or_create_by(original_url: original)

    if link.persisted?
      # FIX: Use the model method here for consistent formatting
      render json: link.to_json_response(request.base_url), status: :ok
    else
      render_error(link.errors.full_messages.join(", "))
    end
  end

  # POST /decode
  def decode
    short_url = params[:url]
    return render_error("URL is required") if short_url.blank?

    code = short_url.split('/').last
    link = ShortLink.find_by(short_code: code)

    if link
      # FIX: Use the model method here as well, or just return original_url as requested
      # The prompt asked for specific JSON format, so we stick to that.
      render json: { original_url: link.original_url }, status: :ok
    else
      render_error("URL not found", :not_found)
    end
  end

  private

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end
end