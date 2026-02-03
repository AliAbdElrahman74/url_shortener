# app/models/short_link.rb
class ShortLink < ApplicationRecord
  validates :original_url, presence: true, format: URI::regexp(%w[http https])
  validates :short_code, uniqueness: true, allow_nil: true

  # After we get an ID from the DB, we generate the short code
  after_create_commit :generate_short_code

  def to_json_response(base_url)
    {
      short_url: "#{base_url}/#{short_code}",
      original_url: original_url
    }
  end

  private

  def generate_short_code
    # We use the ID to generate the code. 
    # Optional: Add an offset (e.g., +100000) to avoid 1-character codes initially.
    self.update_column(:short_code, IdEncoder.encode(self.id))
  end
end
