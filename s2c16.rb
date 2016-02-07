require 'openssl'

def pkcs_padding(block, length)
	diff = length-block.length
	bytes = block.bytes
	diff.times {bytes << diff}
	string = bytes.map{|b| b.chr}.join
	string
end

def gen_rand_key
	prng = Random.new
	# Random.new.bytes(16)
	string = ""
	16.times{string += prng.rand(255).chr}
	string
end

def gen_iv
	iv = []
	prng = Random.new
	16.times { iv << prng.rand(257) }
	iv
end

def xor_byte_arrays(array1,array2)
	array1.zip(array2)
	.map{|pair| pair[0]^pair[1]}
	# .map{|byte| byte.to_s(16)}.join
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

def encrypt(string,key,iv)
	prepend = 'comment1=cooking%20MCs;userdata='
	append = ';comment2=%20like%20a%20pound%20of%20bacon'

	plaintext = prepend+string+append
	plaintext.gsub!(/;/,'";"')
	plaintext.gsub!(/\=/,'"="')
	plaintext = pkcs_padding(plaintext,16)
	encrypt_blocks(get_blocks(plaintext.bytes),key,iv)
end

def decrypt(string,key,iv)
	byte_array = string.scan(/../).map{|b| b.hex}

	padded_plain = decrypt_blocks(get_blocks(byte_array),key,iv)
	plain = validate_pksc_padding(padded_plain)
	# plain.gsub!(/";"/,";")
	# plain.gsub!(/"="/,"=")

	plain
end

def validate_pksc_padding(string)
	string_bytes = string.bytes
	last_block = string_bytes[string_bytes.length-16..string_bytes.length].reverse

	if last_block[0..0] == [0]
		return string_bytes.first(string_bytes.length-1).map{|el| el.chr}.join
	end

	for i in 1..16
		if last_block[0..i-1] == Array.new(i,i)
			return string_bytes.first(string_bytes.length-i).map{|el| el.chr}.join
		end
	end
	raise "Bad Padding"
end

def bit_flipper(ciphertext)
	cipher = ciphertext.scan(/../).map{|b| b.hex}
	cipher[32] = cipher[32] ^ "x".ord ^ ";".ord
	cipher[43] = cipher[43] ^ "\"".ord ^ ";".ord
	cipher[38] = cipher[38] ^ "\=".ord ^ "-".ord
	
	new_ciphertext = cipher.map{|byte| byte.to_s(16).rjust(2,'0')}.join
	new_ciphertext
end

key = gen_rand_key
iv = gen_iv

text = "xxxxxxxxxxxadmin-true"

cipher = encrypt(text,key,iv)

cipher = bit_flipper(cipher)

decrypted = decrypt(cipher,key,iv)

puts decrypted
puts decrypted[48..63]

if decrypted.match(/;admin=true;/)
	puts true
else
	puts false
end