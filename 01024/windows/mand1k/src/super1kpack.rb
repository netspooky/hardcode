require 'optparse'
require 'open3'

PROGDIR = File.dirname(__FILE__)

unpacker_file = "#{PROGDIR}/dx_depacker_gtc.bin"
unpacker_offset = 0x50

extreme_mode = false

optparse = OptionParser.new do |opts|
  opts.banner = 'Usage: super1kpack.rb [options] infile outfile'
  opts.on '-x', '--extreme', 'try very hard during compression' do
    extreme_mode = true
  end
  opts.on '--depacker FILE', 'Use FILE as depacker' do |file|
    unpacker_file = file
  end
  opts.on '--depacker-offset OFF', 'Offset of packed size in depacker' do |off|
    unpacker_offset = Integer(off)
  end
  opts.on '-h', '--help', 'Display this screen' do
    puts opts
    exit
  end
end
begin
  optparse.parse!
rescue OptionParser::InvalidOption => e
  puts e
  exit 1
end

if ARGV.length != 2
  puts optparse
  exit
end

puts 1

unpacker = nil
File.open(unpacker_file, "rb") do |file|
	unpacker = file.read
end

infile, outfile = ARGV

infile_data = nil
File.open(infile, "rb") do |file|
	infile_data = file.read
end

def winexec *args
  unless RUBY_PLATFORM =~ /(win|w)32$/
    args.unshift 'wine'
  end
  system(*args)
end

def kzip filename, *options
  outfile = nil
  while (not outfile) or File.exists? outfile
    outfile = "#{filename}.#{rand 100}.zip"
  end
  options << outfile
  options << filename
  winexec "#{PROGDIR}/kzip", "/q", *options
  winexec "#{PROGDIR}/DeflOpt", outfile
  return outfile
end

def zip7z filename
  outfile = nil
  while (not outfile) or File.exists? outfile
    outfile = "#{filename}.#{rand 100}.zip"
  end
  system("./7za", "a", "-tzip", "-mpass=15", "-mfb=258", outfile, filename)
  winexec "#{PROGDIR}/DeflOpt", outfile
  return outfile
end

def zip2raw filename
  File.open(filename, "rb") do |file|
    if file.read(2) != 'PK'
      raise 'not a zip file'
    end

    unless file.read(2) == "\003\004"
      raise 'format error'
    end
    version = file.read(2).unpack('v').first
    bitflag = file.read(2).unpack('v').first
    use_data_descriptor =  bitflag[3] == 1
    c_method = file.read(2).unpack('v').first
    if c_method != 8
      raise 'unknown compression method'
    end
    last_mod_time = file.read(2)
    last_mod_date = file.read(2)
    crc_32 = file.read(4).unpack('V').first
    size = file.read(4).unpack('V').first
    if use_data_descriptor
      size = :auto
    end
    uncompressed_size = file.read(4).unpack('V').first
    file_name_length = file.read(2).unpack('v').first
    extra_field_length = file.read(2).unpack('v').first
    file_name = file.read(file_name_length)
    file.read(extra_field_length)
    if size != :auto
      return file.read(size)
    else
      output = ''
      buffer = ''
      loop do
        buffer << file.getc
        size += 1
        if buffer.size > 14
          output << buffer[0]
          buffer[0,1] = ''
        end
        if buffer.size == 14
          crc, c_size, u_size, magic_number  = buffer.unpack('VVVa2')
          if c_size == size && c_size <= u_size && magic_number == 'PK'
            break
          end
        end
      end
      return output
    end
  end
end

puts "Input filesize is #{infile_data.length} bytes"
puts "Crunching..."

temp = kzip infile, "/b32", "/rn"
raw = zip2raw temp
File.unlink(temp)
puts "Compressed size is #{unpacker.length + raw.length} bytes"

output = unpacker + raw

output[unpacker_offset] = (raw.length & 0xFF).chr
output[unpacker_offset+1] = (raw.length >> 8).chr

File.open(outfile, "wb") do |out|
  out.print output
end
