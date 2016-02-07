require "openssl"

def gen_rand_key
	prng = Random.new
	# Random.new.bytes(16)
	string = ""
	16.times{string += prng.rand(255).chr}
	string
end

def hex_to_byte_array(string)
	string.scan(/../).map{|x| x.hex}
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

def encrypt_ECB(string,key)
	cipher = OpenSSL::Cipher::AES.new(128, :ECB)
	cipher.encrypt
	cipher.key = key
	encrypted = cipher.update(string) + cipher.final
	encrypted.each_char.map{|char| char.ord.to_s(16).rjust(2,'0')}.join
end

def encrypt_CBC(string,key)
	iv = []
	prng = Random.new
	16.times { iv << prng.rand(256) }
	encrypt_blocks(get_blocks(string.bytes),key,iv)
end

def encryption_oracle(plaintext)
	key = gen_rand_key
	plaintext = plaintext
	#Convert plaintext to bytes
	prng = Random.new
	r1 = 5 + prng.rand(5)
	r2 = 5 + prng.rand(5)
	
	#Append 5-10 bytes at the begninning and end
	beg_bytes = ""
	end_bytes = ""
	r1.times{ beg_bytes << prng.rand(255).chr }
	r2.times{ end_bytes << prng.rand(255).chr }

	plaintext = beg_bytes + plaintext + end_bytes

	encrypt_type = prng.rand(2)
	if encrypt_type == 1
		puts "1 = ECB"
		return encrypt_ECB(plaintext,key)
	else
		puts "2 = CBC"
		return encrypt_CBC(plaintext,key)
	end

end

def detect_encryption(encrypted)
	array = encrypted.scan(/../).map{|x| x.hex}
	n = array.length/16

	sub_sequences = []
	n.times do |i|
		min = i*16
		max = (i+1)*16-1
		sub_sequences << array[min..max]
	end
	if sub_sequences.length != sub_sequences.uniq.length
		puts "ECB"
	else
		puts "CBC"
	end
end

text = "YELLOW SUBMARINEYELLOW SUBMARINEYELLOW SUBMARINEYELLOW SUBMARINEYELLOW SUBMARINEYELLOW SUBMARINE"

20.times do 
	encrypted = encryption_oracle(text)
	detect_encryption(encrypted)
end