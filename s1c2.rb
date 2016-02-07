require 'base64'

def hex_to_byte_array(string)
	string.scan(/../).map{|x| x.hex}
end

def xor_byte_arrays(array1,array2)
	array1.zip(array2)
	.map{|pair| pair[0]^pair[1]}
	.map{|byte| byte.to_s(16)}.join
end

a = "1c0111001f010100061a024b53535009181c"
b = "686974207468652062756c6c277320657965"

puts xor_byte_arrays(hex_to_byte_array(a),hex_to_byte_array(b))