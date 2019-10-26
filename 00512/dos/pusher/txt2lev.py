# txt2lev - convert txt sokoban format to pusher level
#
# syntax:
#    python txt2lev.py <input file> <output file> options num_levels
# where:
#    input file:    a txt file in "common" sokoban format 
#    output file:   hufmann coded binary (ratio typical better than 1:4)
#    options:
#           "-" (single dash) for none
#           "R" for RLE encoded walls
#    num_levels: if given only convert the first num_levels from input
#
# hacked in q&d. but may be used to convert multiple levels.
# the original 50 sokoban levels are compressed down to ca. 2,7 kb.
#
## Whizart, November 2014

import sys

tcr = 0   # bytes read
tbo = 0   # bytes out

# represents encoded level
class bits:
  def __init__(self):
    self.data = ""
    self.bits = 0
    self.byte = 0
    
  def addBit(self, set):
    self.byte = (self.byte << 1) | set
    self.bits = self.bits + 1
    
    if self.bits > 7:
      global tbo
      tbo = tbo + 1
      self.data = self.data + chr(self.byte)
      self.byte = 0
      self.bits = 0
      
  def addWall(self, num=1):    
    if num < 6 or not useRle:      
      for i in range(num):
        self.addBit(0)
        self.addBit(1)
    else:
      num = num - 6
      self.addBit(0)
      self.addBit(0)
      self.addBit(0)
      self.addBit(0)      
      self.addBit(1)      
      self.addBit(1)
      self.addBit(1)

      numrest = 0
      
      if num > 7:
        numrest = num - 7
        num = 7
            
      for i in range(3):
        self.addBit((num & 4) >> 2)
        num = num << 1      
      
      if numrest > 0:
        self.addWall(numrest)
        
  def addFloor(self):
    self.addBit(1)
        
  def addBox(self):
    self.addBit(0)
    self.addBit(0)
    self.addBit(1)
    
  def addBin(self):
    self.addBit(0)
    self.addBit(0)
    self.addBit(0)
    self.addBit(1)
        
  def addPusher(self):
    for i in range(4):
      self.addBit(0)
    self.addBit(1)
    self.addBit(1)

    if useRle:
      self.addBit(0)

  def addBoxOnBin(self):
    for i in range(4):
      self.addBit(0)
    self.addBit(1)
    self.addBit(0)
    
  def addReturn(self):
    for i in range(5):
      self.addBit(0)   
    
  def addPadding(self):
    if self.bits > 0:    
      n = 8 - self.bits
      
      for i in range(n):
        self.addBit(0)

def encodeMultipleWalls(encoded, lcnum, lastchar):
  if lcnum == 1:
    if lastchar == '#':
      encoded.addWall()
  elif lcnum > 1:
    if lastchar == '#':
      encoded.addWall(lcnum)
            
def encode(level):
  encoded = bits()
  lastchar = chr(0)
  lcnum = 0
  firstLine = True

  for line in level:
    if not firstLine:
      encoded.addReturn() 
    firstLine = False
    
    for char in line:
      global tcr
      tcr = tcr + 1

      if lcnum > 0 and lastchar != char:
        encodeMultipleWalls(encoded, lcnum, lastchar)
        lcnum = 0
      lastchar = char
      if char == '#':
        lcnum = lcnum + 1
      elif char == ' ':
        encoded.addFloor()
      elif char == '$':
        encoded.addBox()
      elif char == '.':
        encoded.addBin()
      elif char == '@':
        encoded.addPusher()
      elif char == '*':
        encoded.addBoxOnBin()
      elif char != '\n':
        print "unknown char: " + repr(char)

    encodeMultipleWalls(encoded, lcnum, lastchar)
    lcnum = 0

  encoded.addPadding()
  return encoded
    
inLevel = False
levels = 0
leveloutfile = "level.bin"

print "input: " + sys.argv[1]

if (len(sys.argv) > 2):
  leveloutfile = sys.argv[2]

print "output: " + leveloutfile
of = open(leveloutfile, "wb")

options = ""
nlev = 99999

if (len(sys.argv) > 3):
  options = sys.argv[3]

print "options: " + options

if (len(sys.argv) > 4):
  nlev = int(sys.argv[4])

print "max levels: " + str(nlev)
  
useRle = 'R' in options
print "use RLE: " + str(useRle)
levels = []
n = 0

for line in open(sys.argv[1]).readlines():
  if "#" in line:
    if not inLevel:
      inLevel = True
      myLevel = []
    myLevel.append(line)
        
  elif inLevel:
    if ";" in line:
      levels.append(encode(myLevel))
    inLevel = False
    n = n + 1
    if n >= nlev:
      break

for encoded in levels:
  size = len(encoded.data) + 1
  of.write(chr(size))
  of.write(encoded.data)

print "**** chars read: " + str(tcr)
print "**** bytes out:  " + str(tbo)

of.close()
