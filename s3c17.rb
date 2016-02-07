require "base64"
require "openssl"

STRINGS = ["MDAwMDAwTm93IHRoYXQgdGhlIHBhcnR5IGlzIGp1bXBpbmc=", "MDAwMDAxV2l0aCB0aGUgYmFzcyBraWNrZWQgaW4gYW5kIHRoZSBWZWdhJ3MgYXJlIHB1bXBpbic=",
	"MDAwMDAyUXVpY2sgdG8gdGhlIHBvaW50LCB0byB0aGUgcG9pbnQsIG5vIGZha2luZw==", "MDAwMDAzQ29va2luZyBNQydzIGxpa2UgYSBwb3VuZCBvZiBiYWNvbg==", 
	"MDAwMDA0QnVybmluZyAnZW0sIGlmIHlvdSBhaW4ndCBxdWljayBhbmQgbmltYmxl", "MDAwMDA1SSBnbyBjcmF6eSB3aGVuIEkgaGVhciBhIGN5bWJhbA==",
	"MDAwMDA2QW5kIGEgaGlnaCBoYXQgd2l0aCBhIHNvdXBlZCB1cCB0ZW1wbw==", "MDAwMDA3SSdtIG9uIGEgcm9sbCwgaXQncyB0aW1lIHRvIGdvIHNvbG8=",
	"MDAwMDA4b2xsaW4nIGluIG15IGZpdmUgcG9pbnQgb2g=", "MDAwMDA5aXRoIG15IHJhZy10b3AgZG93biBzbyBteSBoYWlyIGNhbiBibG93"]

def gen_rand_key
	string = ""
	16.times{string << rand(256).chr}
	string
end

def gen_iv
	iv = []
	16.times {iv << rand(256)}
	iv
end

def pkcs_padding(string, length=16)
	pad_len = (length-string.length) % length
	if pad_len == 0
		16.times {string << 16.chr}
	else
		pad_len.times {string << pad_len.chr}
	end
	string
end

def validate_pksc_padding(string)
	last_chr = string[-1,1]

	correct_padding = last_chr*last_chr.ord
	correct_padding = Regexp.escape(correct_padding)

	if string.match(correct_padding)
		return true
	else
		raise "Invalid padding"
	end
end

def xor_byte_arrays(array1,array2)
	array1.zip(array2)
	.map{|pair| pair[0]^pair[1]}
end

def get_blocks(array,length = 16)
	blocks = []
	n = (array.length/length).floor

	n.times do
		blocks << array[0..length-1]
		array.shift(length)
	end

	if array.empty?
		return blocks
	else
		diff = length - array.length
		blocks << array + Array.new(diff,diff)
		return blocks
	end
end

def encrypt_blocks(blocks,key,iv)
	
	cypher_blocks = []

	cypher_blocks << encrypt_string(xor_byte_arrays(blocks[0],iv),key)

	if blocks.length > 1
		for i in 1..blocks.length-1
			cypher_blocks[i] = encrypt_string(xor_byte_arrays(blocks[i],cypher_blocks[i-1]),key)
		end
	end
	# return cypher_blocks.flatten
	return cypher_blocks.flatten.map{|byte| byte.to_s(16).rjust(2,'0')}.join
end

def decrypt_blocks(blocks,key,iv)
	plaintext_blocks = []

	plaintext_blocks << xor_byte_arrays(decrypt_string(blocks[0],key),iv)
	if blocks.length > 1
		for i in 1..blocks.length-1
			plaintext_blocks[i] = xor_byte_arrays(decrypt_string(blocks[i],key),blocks[i-1])
		end
	end

	return plaintext_blocks.map{|block| block.map{|b| b.chr}.join }.join

end

def encrypt_string(array,key)
	data = array.map{|ele| ele.chr}.join
	cipher = OpenSSL::Cipher::AES.new(128, :ECB)
	cipher.padding = 0
	cipher.encrypt
	cipher.key = key
	encrypted = cipher.update data
	encrypted << cipher.final
	return encrypted.bytes
end

def decrypt_string(array,key)
	data = array.map{|ele| ele.chr}.join
	decipher = OpenSSL::Cipher::AES.new(128, :ECB)
	decipher.padding = 0
	decipher.decrypt
	decipher.key = key
	decrypted = decipher.update data
	return decrypted.bytes
end

def encrypter	
	# string = STRINGS.sample
	# plain = Base64.decode64(string)
	# puts plain
	plain = "yellow submarine yellos siub"
	plaintext = pkcs_padding(plain)
	iv = gen_iv
	cipher = encrypt_blocks(get_blocks(plaintext.bytes),KEY,iv)
	return cipher, iv
end

def decrypter(ciphertext,iv)
	byte_array = ciphertext.scan(/../).map{|b| b.hex}
	padded_plain = decrypt_blocks(get_blocks(byte_array),KEY,iv)
	begin
		plain = validate_pksc_padding(padded_plain)
		return true
	rescue 
		return false
	end
end

KEY ||= gen_rand_key

result = encrypter
encrypted = result[0]
iv = result[1]

encrypted_bytes = encrypted.scan(/../).map{|b| b.hex}

num_blocks = encrypted_bytes.length/16

#Get C2 as last block
c2 = encrypted_bytes[(encrypted_bytes.length-16)..encrypted_bytes.length]

#c1 is second last block
c1 = encrypted_bytes[(encrypted_bytes.length-32)..(encrypted_bytes.length-17)]

#Get C1p
c1p = Array.new(15,rand(255))

int = 0

for i in 0..255
	int = i
	cipher = c1p + [i]
	cipher = cipher + c2
	cipher = cipher.map{|byte| byte.to_s(16).rjust(2,'0')}.join
	# puts cipher
	if decrypter(cipher,iv)
		break
	end
end

puts int
puts c1[15]

