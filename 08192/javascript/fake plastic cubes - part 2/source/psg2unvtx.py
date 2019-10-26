import sys

f = open(sys.argv[1], 'rb')
signature = f.read(4)

if signature != "PSG\x1a":
	raise Exception("not a PSG file")

f.read(0x0c)  # skip blank bytes

regs = [0] * 14

streams = [[] for i in range(0, 14)]

is_first_frame = True


def save_state():
	global is_first_frame
	if is_first_frame:  # first frame data is bogus - skip it
		is_first_frame = False
		return

	for r, v in enumerate(regs):
		streams[r].append(v)

while True:
	command_byte = f.read(1)
	if command_byte == '':
		save_state()
		break
	command = ord(command_byte)

	if command == 0xfd:
		save_state()
		break
	elif command == 0xff:
		save_state()
	elif command == 0xfe:
		count = ord(f.read(1))
		for i in range(1, count):
			save_state()
	else:
		val = ord(f.read(1))
		regs[command] = val

f.close()

outfile = open(sys.argv[2], 'wb')
# outfile.write(pack('!I', len(streams[0])))  # - we'll infer this from filesize instead

for channel in range(0, 14):
	channel_data = ''.join([chr(i) for i in streams[channel]])
	outfile.write(channel_data)

outfile.close()
