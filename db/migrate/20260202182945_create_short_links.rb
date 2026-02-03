class CreateShortLinks < ActiveRecord::Migration[7.2]
  def change
    create_table :short_links do |t|
      t.text :original_url, null: false
      t.string :short_code
      t.timestamps
    end

    # Fast lookup for decoding
    add_index :short_links, :short_code, unique: true
  end
end
