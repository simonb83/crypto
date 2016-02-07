require 'cgi'
require 'json'
require 'openssl'

def gen_rand_key
	prng = Random.new
	# Random.new.bytes(16)
	string = ""
	16.times{string += prng.rand(255).chr}
	string
end

def parse(string)
	# string = "{\n"
	params = CGI.parse(string)
	params.each do |k,v|
		params[k] = v.join
	end
	params.to_json
end

def profile_for(email)
	email.gsub!(/&|=/,"")
	profile = {}
	profile["email"] = email
	profile["uid"] = 10
	profile["role"] = 'user'
	string = []
	profile.each do |k,v|
		string << "#{k}=#{v}"
	end
	string.join("&")
end

def encrypt_profile(profile,key)
	# key = gen_rand_key
	cipher = OpenSSL::Cipher::AES.new(128, :ECB)
	cipher.encrypt
	cipher.key = key
	encrypted = cipher.update(profile) + cipher.final
	return [encrypted.bytes.map{|byte| byte.to_s(16).rjust(2,'0')}.join, key]
end

def decrypt_profile(ciphertext,key)
	ciphertext = ciphertext.scan(/../).map{|x| x.hex.chr}.join
	# ciphertext = ciphertext.map{|x| x.chr}.join
	cipher = OpenSSL::Cipher::AES.new(128, :ECB)
	cipher.decrypt
	cipher.key = key
	decrypted = cipher.update(ciphertext) + cipher.final
	return decrypted
end

# print parse("foo=bar&baz=qux&zap=zazzle")
# puts profile_for("simon.bedford@gmail.com&user=admin")
# puts parse(profile_for("simon.bedford@gmail.com&user=admin"))

key = gen_rand_key
BLOCK = 16

text_1 = "a"*(16 - "user=")
text_2 = "aaaaaaaaaaaaa"

# puts text_1.length

encrypted_1 = encrypt_profile(profile_for(text_1),key)
encrypted_2 = encrypt_profile(profile_for(text_2),key)

encrypted_bytes_1 = encrypted_1[0].scan(/../).map{|x| x.hex}
encrypted_bytes_2 = encrypted_2[0].scan(/../).map{|x| x.hex}

# puts encrypted_bytes.length
# length = encrypted_bytes.length/16

encrypted_bytes = encrypted_bytes_2[0..31] + encrypted_bytes_1[16..31] + encrypted_bytes_1[0..15] + encrypted_bytes_1[32..47]

encrypted_bytes = encrypted_bytes.map{|b| b.to_s(16).rjust(2,'0')}.join

decrypted_profile = decrypt_profile(encrypted_bytes,key)

puts decrypted_profile
puts parse(decrypted_profile)

# puts decrypt_profile(encrypted[0],encrypted[1])
