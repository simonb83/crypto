def hexToB64(string)
	b = string.scan(/../).map {|x| x.hex.chr }.join
	return [b].pack('m0')
end

puts "Enter string"

a = gets.chomp

# a = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"

puts hexToB64(a)