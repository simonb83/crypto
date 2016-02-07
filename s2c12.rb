require "base64"
require "openssl"

def gen_rand_key
	prng = Random.new
	# Random.new.bytes(16)
	string = ""
	16.times{string += prng.rand(255).chr}
	string
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

def encryption_oracle(plaintext,key)
	plaintext = plaintext
	
	unknown = "Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK"
	b64_decode = Base64.decode64(unknown)
	# b64_decode = "This should be a good one I think!"
	plaintext = plaintext + b64_decode
	encrypt_ECB(plaintext,key)
end

def encrypt_ECB(string,key)
	cipher = OpenSSL::Cipher::AES.new(128, :ECB)
	cipher.encrypt
	cipher.key = key
	encrypted = cipher.update(string)
	# encrypted.each_char.map{|char| char.ord.to_s(16).rjust(2,'0')}.join
	encrypted.bytes
end


#Generate global key
key = gen_rand_key

#Check Block Length
# for i in 1..48
# 	encrypted = encryption_oracle("A"*i, key)
# 	block = (i/2.0).floor
# 	if encrypted[0..block-1] == encrypted[block..2*block-1]
# 		puts "BLOCK LENGTH is #{block}"
# 	end
# end
BLOCK = 16

# puts encryption_oracle("AAAAAAAAAAAAAAA",key).scan(/../).map{|x| x.hex}.size

#Detect if is ECB
# text = "YELLOW SUBMARINEYELLOW SUBMARINEYELLOW SUBMARINEYELLOW SUBMARINEYELLOW SUBMARINEYELLOW SUBMARINE"

# detect_encryption(encryption_oracle(text,key))

alphabet = (0..255).to_a
num_blocks = 12

letters = {}

for j in 0..(num_blocks-1)

	letters[j] = []

	for i in 0..15
		results = {}

		sub = "A"*(BLOCK-(i+1))
		prior = letters.select{|k,v| k < j}.values.flatten.join
		
		for letter in alphabet
			results[letter.chr] = encryption_oracle(sub+prior+(letters[j][0..i-1].join)+letter.chr,key)[(j*16)..(j*16+15)]
		end

		test = encryption_oracle("A"*(BLOCK-(i+1)),key)[(j*16)..(j*16+15)]

		letters[j][i] = results.key(test)
	end
end

print "\n"
print letters.values.flatten.join.strip
print "\n"