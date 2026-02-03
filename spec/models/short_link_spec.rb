require 'rails_helper'

RSpec.describe ShortLink, type: :model do
  describe 'validations' do
    it 'is valid with a valid URL' do
      link = ShortLink.new(original_url: 'https://google.com')
      expect(link).to be_valid
    end

    it 'is invalid without a URL' do
      link = ShortLink.new(original_url: nil)
      expect(link).not_to be_valid
    end

    it 'is invalid with a bad URL format' do
      link = ShortLink.new(original_url: 'bad-url')
      expect(link).not_to be_valid
    end
  end

  describe '#generate_short_code' do
    it 'automatically generates a code after creation' do
      link = ShortLink.create!(original_url: 'https://example.com')

      # We expect a code to exist
      expect(link.short_code).to be_present

      # We expect it to be a string representation of the ID
      # Note: exact value depends on your encoder implementation
      expect(link.short_code).not_to eq(link.id.to_s)
    end

    it 'ensures codes are unique for different records' do
      link1 = ShortLink.create!(original_url: 'https://a.com')
      link2 = ShortLink.create!(original_url: 'https://b.com')

      expect(link1.short_code).not_to eq(link2.short_code)
    end
  end
end