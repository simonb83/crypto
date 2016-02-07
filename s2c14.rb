require "base64"
require "openssl"

	def sub_array_index(array1,array2)
		sub_array = array1.map{|l| l.chr}.join
		main_array = array2.map{|l| l.chr}.join

		if main_array.include?(sub_array)
			return main_array.index(sub_array)
		else
			return nil
		end
	end


def gen_rand_key
	prng = Random.new
	# Random.new.bytes(16)
	string = ""
	16.times{string += prng.rand(255).chr}
	string
end

def gen_rand_text
	p = Random.new
	string = ""
	# n = p.rand(65)
	n = 8
	n.times{string += p.rand(256).chr}
	string
end

def detect_encryption(encrypted)
	# array = encrypted.scan(/../).map{|x| x.hex}
	n = encrypted.length/16

	sub_sequences = {}
	n.times do |i|
		min = i*16
		max = (i+1)*16-1
		sub_sequences[i] = encrypted[min..max]
	end

	repeats = {}
	sub_sequences.each do |k,v|
		if repeats[v]
			repeats[v][1] += 1
			repeats[v][0] << k
		else
			repeats[v] = [[k],1]
		end
	end

	repeated = repeats.select{|k,v| v[1] == 2}

	if !repeated.empty?
		return repeated.first
	else
		return false
	end
end

def encryption_oracle(prefix,plaintext,key)
	plaintext = plaintext
	
	unknown = "Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK"
	b64_decode = Base64.decode64(unknown)
	# b64_decode = "This should be a good one I think!"
	plaintext = prefix + plaintext + b64_decode
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
BLOCK = 16
prefix = gen_rand_text

#Find where random text ends

text = "A"*16*2
b = -1
repeated = false

until repeated
	b += 1
	new_text = text + "A"*b
	repeated = detect_encryption(encryption_oracle(prefix,new_text,key))
end

#First incidence of repeating block is i
norm_index = repeated[1].flatten[0] + 2
# puts "i is #{norm_index}"
# puts "b is #{b}"

#Base text needed is
base = text + "A"*b

alphabet = (0..255).to_a
num_blocks = encryption_oracle(prefix,base,key).length/16

letters = {}

for j in 0..num_blocks

	letters[j] = []

	for i in 0..15
		results = {}

		sub = base + "B"*(BLOCK-(i+1))
		prior = letters.select{|k,v| k < j}.values.flatten.join
		
		for letter in alphabet
			results[letter.chr] = encryption_oracle(prefix,sub+prior+(letters[j][0..i-1].join)+letter.chr,key)[(norm_index*16+(j*16))..(norm_index*16+(j*16+15))]
		end
		
		test = encryption_oracle(prefix,base + "B"*(BLOCK-(i+1)),key)[(norm_index*16+(j*16))..(norm_index*16+(j*16+15))]

		letters[j][i] = results.key(test)
	end
end

print "\n"
print letters.values.flatten.join.strip
print "\n"

