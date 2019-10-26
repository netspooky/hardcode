def encode(string):
  counter=1
  previous=out=""
  for ind,i in enumerate(string):
    if i==previous: counter+=1; previous=i
    if ind+1==len(string) or i!=previous: 
      if counter>2:
        if ind+1==len(string): out+="%i%s"%(counter,i)
        else: out+="%i%s"%(counter,previous)
      else:
        if ind+1==len(string): out+=(i*counter)
        else: out+=(previous*counter)
      counter=1;previous=i
  return out

def decode(string):
  counter=""
  out=""
  for i in string:
    if i.isdigit():counter+=i
    else: 
      if counter:out+=(int(counter)*i)
      else:out+=i
      counter=""
  return out

def encodescroll():
  with open("./vscroll","r") as scrollin:
    with open("./rsescroll","w+") as scrollout:
      for line in scrollin: scrollout.write(encode(line.rstrip('\n'))+'\n')

def decodescroll():
  with open("./rsescroll","r") as scrollin:
    with open("./finalscroll","w+") as scrollout:
      for line in scrollin: scrollout.write(decode(line.rstrip('\n'))+'\n')
