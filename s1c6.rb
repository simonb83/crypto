require "base64"

class Array
	def safe_transpose
		max_size = self.map(&:size).max
		self.dup.map{|r| r << nil while r.size < max_size; r}.transpose
	end
end

def hex_to_byte_array(string)
	string.scan(/../).map{|x| x.hex}
end

def hamming_distance(string1,string2)
	s1_bin = string1.unpack("B*")[0]
	s2_bin = string2.unpack("B*")[0]
	dist = 0
	if s1_bin.length != s2_bin.length
		puts "distance cannot be calculated"
		return
	else
		s1_bin.length.times do |n|
			dist += s1_bin[n].to_i^s2_bin[n].to_i
		end
	end
	return dist
end

def byte_array_to_string(array)
	string = ""
	array.each do |ele|
		string += ele.chr
	end
	string
end

def score(text)
	letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	common = "ETAOINSHRDLCUMWFGYPBVKJXQZ"
	common_top = "ETAOIN"
	common_bottom = "VKJXQZ"

	text_freqs = {}

	text.upcase.each_char do |char|
		if letters.include?(char)
			if text_freqs.has_key?(char)
				text_freqs[char] += 1
			else
				text_freqs[char] = 1
			end
		end
	end

	text_top = text_freqs.sort_by{|k,v| -v}.first(6).map{|k,v| k}.join

	text_bottom = text_freqs.sort_by{|k,v| -v}.last(6).map{|k,v| k}.join

	score = 0
	score = -20 if text.gsub(/\s/,'').scan(/\W/).count/text.length.to_f > 0.1
	# score = -5 if text_freqs.length < 20
	
	text_top.each_char do |char|
		score += 1 if common_top.include?(char)
	end

	text_bottom.each_char do |char|
		score += 1 if common_bottom.include?(char)
	end
	score
end

def xor_byte_arrays(array1,array2)
	array1.zip(array2)
	.map{|pair| pair[0]^pair[1]}
	.map{|byte| byte.chr}.join
end

def decrypt(array,key)

	n = 0
	decrypted = ""

	array.each do |byte|
		key_byte = key[n % key.length].ord
		decrypted += (byte ^ key_byte).chr
		n += 1
	end

	return decrypted
end

def select_best_key(hash)
	hash.sort_by{ |k,v| -v}.first[0].chr
end

def variations(a)
  first = a.first
  if a.length==1 then
    first
  else
    rest = variations(a[1..-1])
    first.map{ |x| rest.map{ |y| "#{x}#{y}" } }.flatten
  end
end

# puts hamming_distance("this is a test","wokka wokka!!!")

#Read coded text file
encoded = File.read("6.txt")
input = encoded.unpack('m').join
byte_array = input.bytes

# test = "1c27333e3d3b322721352d37637235262a72032f2139612129720420283e20202b72292f3c7220223c3d612d273b313e2a366127217c61073b72283d6f312e202b27223a263c266e2e3c612b212334273d2b612721262e6e3b3a246e3d3b32256f3d276e2e3c612b2c3d2f21223b226e2c20203d277228286f34343a3a20246e2c3e28232e26246e2c3a20202837613c3a3e243d6f2024202b37336e2c3d202263722e27237220202b72262f3c72203d3c37353d6f252e3c3b3a2d2b3c216f6e1b3a246e293b2f2a263c263d6f2528222372232b6f3b2f3a2a20243d3b3b2f29747224382a3c6127297235262a7224203e27283c3672352b2e3f612f3d37612f233333232a36612c367235262a7231213b372f3a26332d6e2a2a352b212661212972323a3d332f2a2a36612f3c21243a3c7e613a2737386e2c332f6e2733332a232b61232e39246e3b3a24273d72222f3c37612c23272f3a232b6128202061282a33336e2034612d3d37203a263c266e2e72323a2e3f312b2b376f6e1c3d2c2b6f312e2322372f3a2e262e3c3c72203c2827246e3b3a203a6f26292b6f252e3c2336613d273d34222b722221212628203a37613a2072252b39372d213f7222262a33316e2a3c243c282b612f2136613a2e39246e2e7222262e3c222b6f26292f3b72362b6f3120206f33252f3f26613a207236262e2624382a20612d233b2c2f3b37612d27332f292a72233c263c263d617200202b722d2b2e36243c3c722e286f26292b6f342e3d3c3b2d6e292724226f33323d2a26612d2333323d637236213d26296e2024243c6f76756e3b202822233b2e2063722c2f3672232b6f31343c3d372f3a232b61232020246e383d333c2637256e2d2b613a2737613e23272c232a26282028722e272372313c2631246e3b3a20206f26292b6f372c2c3d2b2e202631612a2624243d3b3f24203b722c2139372c2b21266f"
# byte_array = hex_to_byte_array(test)

distances = {} 

for k in 2..40
	s1 = byte_array_to_string(byte_array[0..k-1])
	s2 = byte_array_to_string(byte_array[k..k+k-1])
	s3 = byte_array_to_string(byte_array[2*k..3*k-1])
	s4 = byte_array_to_string(byte_array[3*k..4*k-1])

	dist1 = hamming_distance(s1,s2)/k.to_f if hamming_distance(s1,s2)
	dist2 = hamming_distance(s2,s3)/k.to_f if hamming_distance(s2,s3)
	dist3 = hamming_distance(s3,s4)/k.to_f if hamming_distance(s3,s4)
	dist4 = hamming_distance(s1,s4)/k.to_f if hamming_distance(s1,s4)

	distances[k] = (dist1 + dist2 + dist3 + dist4)/4
end

best_key_size = distances.sort_by{ |k,v| v}.first(3).map{ |k,v| k}
# best_key_size = [29]
# puts best_key_size


# KEYS = [5,3,2,13,11]
file = File.open("sols.txt","w")

best_key_size.each do |i|

size = i
# size = 4

#Break ciphertext into blocks of length KEYSIZE

blocks = byte_array.each_slice(size).to_a
transposed = blocks.safe_transpose

key = []

# with_u = xor_byte_arrays(transposed[3],Array.new(transposed[3].length,64))
# puts with_u
# puts score(with_u)

# with_O = xor_byte_arrays(transposed[3],Array.new(transposed[3].length,109))
# puts with_O
# puts score(with_O)


transposed.each do |block|
	block.delete(nil)
	length = block.length
	results = {}

	for i in 0..255
		results[i.chr] = score(xor_byte_arrays(block,Array.new(length,i)))
	end
	
	# print results.sort_by{|k,v| -v}.first(5)
	key << select_best_key(results)
end

puts key.join

# print key.join+"\n"
# file.write("Starting New Key Size\n\n")
# file.write("Key Length: #{size}\n\n")
# file.write("Key: #{key.join}\n\n")
# file.write(decrypt(byte_array,key.join)+"\n\n\n")
# print decrypt(byte_array,key.join)
# print decrypt(byte_array,"Terminator X: Bring the noise")

end

file.close
