def hex_to_byte_array(string)
	string.scan(/../).map{|x| x.hex}
end

def array_to_hex_string(array)
	string = ""
	array.each do |ele|
		string += ele.to_s(16).rjust(2,'0')
	end
	string
end

def repeating_string(array)
	n = array.length/16

	sub_sequences = []

	n.times do |i|
		min = i*16
		max = (i+1)*16-1
		sub_sequences << array[min..max]
	end

	puts array_to_hex_string(array) if sub_sequences.length != sub_sequences.uniq.length
end

def byte_array_to_string(array)
	string = ""
	array.each do |ele|
		string += ele.chr
	end
	string
end

file = File.open("8.txt","r")

texts = []

file.each_line do |line|
	texts << hex_to_byte_array(line)
end

texts.each do |text|
	repeating_string(text)
end