# app/services/id_encoder.rb
module IdEncoder
  ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".split("")
  BASE = ALPHABET.length

  def self.encode(id)
      return ALPHABET[0] if id == 0
      s = ""
      while id > 0
      s << ALPHABET[id % BASE]
      id /= BASE
      end
      s.reverse
  end

  def self.decode(code)
      num = 0
      code.each_char { |c| num = num * BASE + ALPHABET.index(c) }
      num
  end
end
