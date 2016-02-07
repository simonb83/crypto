require "openssl"
require "base64"

def hex_to_byte_array(string)
	string.scan(/../).map{|x| x.hex}
end

def get_blocks(array,length)
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

BLOCK_LENGTH = 16
IV = Array.new(BLOCK_LENGTH,0)
KEY = "YELLOW SUBMARINE"

data = "This is a sentence of a carefully chosen length with."

#Turn ciphertext into bytes and then get blocks of length BLOCK_LENGTH
# data_bytes = data.bytes
# blocks = get_blocks(data_bytes,BLOCK_LENGTH)

# encrypted_data = encrypt_blocks(blocks,KEY,IV)

# cipher_bytes = hex_to_byte_array(encrypted_data)
# cipher_blocks = get_blocks(cipher_bytes,BLOCK_LENGTH)
# puts decrypt_blocks(cipher_blocks,KEY,IV).strip

f = File.read("10.txt")
text = Base64.decode64(f)
cipher_bytes = text.bytes
blocks = get_blocks(cipher_bytes,BLOCK_LENGTH)
puts decrypt_blocks(blocks,KEY,IV)


