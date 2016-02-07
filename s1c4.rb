def hex_to_byte_array(string)
	string.scan(/../).map{|x| x.hex}
end

def xor_byte_arrays(array1,array2)
	array1.zip(array2)
	.map{|pair| pair[0]^pair[1]}
	.map{|byte| byte.chr}.join
end

def score(text)
	freqs = {"e"=> 0.12702,
	"t" => 0.09056,
	"a" => 0.08167,
	"o" => 0.07507,
	"i" => 0.06966,
	"n" => 0.06749,
	"s" => 0.06327,
	"h" => 0.06094,
	"r" => 0.05987,
	"d" => 0.04253,
	"l" => 0.04025,
	"c" => 0.02782,
	"u" => 0.02758,
	"m" => 0.02406,
	"w" => 0.02360,
	"f" => 0.02228,
	"g" => 0.02015,
	"y" => 0.01974,
	"p" => 0.01929,
	"b" => 0.01492,
	"v" => 0.00978,
	"k" => 0.00772,
	"j" => 0.00153,
	"x" => 0.00150,
	"q" => 0.00095,
	"z" => 0.00074}

	total = text.length.to_f
	#Remove non-word characters
	#Penalise text with lots of non-space characters

	if text.gsub(/\s/,'').scan(/\W/).count/total > 0.05
		score = -5
	else
		score = 0
	end
	text.downcase.each_char do |char|
		#Calculate frequency of char in word
		f = (text.count(char).to_f/total.to_f)
		#Calculate difference from frequency and add to score
		score += (f-freqs[char]).abs if freqs[char]
	end
	return score
end

f = File.open("4.txt","r")
line_number = 1

global_score = {}

f.each_line do |line|
	# puts "Decrypting line: #{line_number} - #{line}"
	encoded_bytes = hex_to_byte_array(line)
	length = encoded_bytes.length
	results = {}
	
	for i in 0..255
		results[i] = score(xor_byte_arrays(encoded_bytes,Array.new(length,i)))
	end
	
	results.sort_by{|i,f| -f}.first(5).each do |k,v|
		global_score[v] = [k,line]
	end
	# line_number += 1
end


global_score.sort_by{|i,f| -i}.first(10).each do |k,v|
	byte_array = hex_to_byte_array(v[1])
	length = byte_array.length
	decrypted = xor_byte_arrays(byte_array, Array.new(length,v[0]))
	puts "Score: #{k}, Key: #{v[0]}, Decrypted: #{decrypted}"
end