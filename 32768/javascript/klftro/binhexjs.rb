#!/usr/bin/env ruby

ARGV.each do |filename|
	File.open(filename, 'rb') do |f|
		bytes = f.read()
		bytes_hex = bytes.each_byte.collect{|x| sprintf("%02x",x)}
		puts "\"#{bytes_hex}\".replace(/../g, function(r) {return String.fromCharCode(parseInt(r,16))})"
	end
end
