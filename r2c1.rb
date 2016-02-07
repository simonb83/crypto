def pkcs_padding(block, length=16)
	diff = (length-block.length) % length
	bytes = block.bytes
	if diff == 0
		16.times {bytes << 0}
	else
		diff.times {bytes << diff}
	end
	string = bytes.map{|b| b.chr}.join
	string
end

def validate_pksc_padding(string)
	last_chr = string[-1,1]

	correct_padding = last_chr*last_chr.ord
	correct_padding = Regexp.escape(correct_padding)

	if string.match(correct_padding)
		return true
	else
		raise "Invalid padding"
	end
end

padded = pkcs_padding("yellow submarine yellos siub")

begin
	puts validate_pksc_padding(padded)
rescue
	puts "There was an error"
end