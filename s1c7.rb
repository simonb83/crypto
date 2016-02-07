require "base64"
require "openssl"

encoded = File.read("7.txt")

encrypted = Base64.decode64(encoded)

key = "YELLOW SUBMARINE"

decipher = OpenSSL::Cipher::AES.new(128, :ECB)

decipher.decrypt
decipher.key = key
plain = decipher.update(encrypted) + decipher.final

puts plain

