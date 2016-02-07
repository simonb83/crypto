def encrypt(text,key)
	n = 0
	encrypted = ""

	text.each_char do |char|
		char_byte = char.ord
		key_byte = key[n % key.length].ord
		encrypted += (char_byte ^ key_byte).to_s(16).rjust(2,'0')
		n += 1
	end
	
	return encrypted
end

def decrypt(text,key)

	n = 0
	decrypted = ""

	text.scan(/../).each do |char|
		char_byte = char.hex
		key_byte = key[n % key.length].ord
		decrypted += (char_byte ^ key_byte).chr
		n += 1
	end

	return decrypted
end

def hexToB64(string)
	b = string.scan(/../).map {|x| x.hex.chr }.join
	return [b].pack('m0')
end

# test = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
test = "Surprisingly, the Bank of England has also chipped in. It is conducting an enquiry into the risk of an economic crash if future climate change rules render coal, oil and gas assets worthless. The findings will be interesting; even if the enquiry team are alarmed by the potential extent of stranded assets, they can hardly make their case bluntly for fear of creating a stampede. Some commentators argue that the world should continue to develop cheap energy and take a chance that we can adapt to whatever climate change brings. And leaders of the fossil fuel asset class, worth over $4 trillion, may be currently more worried by the plummeting oil price than the embryonic divestment movement."
KEY = "ORAN"

File.open("6a.txt","w"){|f| f.write(hexToB64(encrypt(test,KEY)))}

# puts decrypt(encrypt(test,KEY),KEY)

# text = ""
# file = File.open("pswd.txt","r")

# file.each_line do |line|
# 	text += line.gsub(/(“|”)/,'"')
# end

# File.open("encrypted.txt","w"){|f| f.write(encrypt(text,KEY))}

# encrypted_text = File.read("encrypted.txt")

# File.open("decrypted.txt","w"){|f| f.write(decrypt(encrypted_text,KEY))}