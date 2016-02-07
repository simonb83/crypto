def validate_pksc_padding(string)
	string_bytes = string.bytes
	last_block = string_bytes[string_bytes.length-16..string_bytes.length].reverse

	for i in 1..16
		if last_block[0..i-1] == Array.new(i,i)
			return string_bytes.first(string_bytes.length-i).map{|el| el.chr}.join
		end
	end
	raise "Bad Padding"
end

test = "ICE ICE BABY\x04\x04\x04\x04"
# test_2 = "ICE ICE BABY\x05\x05\x05\x05"
# test_3 = "ICE ICE BABY\x01\x02\x03\x04"
test_4 = "A"*15+"\x01"
test_5 = "YELLOW SUBMARINE"+"\x10"*16

begin
	puts validate_pksc_padding(test)
	# puts validate_pksc_padding(test_2)
	# puts validate_pksc_padding(test_3)
	puts validate_pksc_padding(test_4)
	puts validate_pksc_padding(test_5)
rescue
	puts "error"
end