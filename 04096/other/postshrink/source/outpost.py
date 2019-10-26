#!/usr/bin/env python
import sys,os,re,types,string

re_dsc=re.compile(r'^%[!%#].*$',re.MULTILINE)
re_string=re.compile(r'\({1}.*?[^\\\)]\)[^\)]')
re_comment=re.compile(r'%.*$',re.MULTILINE)

Aggregates=("bind_def","-1_roll","1_index","2_index","3_index")
Redundancies=("exch exch","3_-1_roll 3_-1_roll 3_-1_roll")
CharSet="!#$&*+,-:;?@ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

Remap={}
NoRemap={}
UserSymbols={}
SymbolCount={}
RemapAll=False

################################################################################
### TOKENIZER                                                                ###
################################################################################

def Escape(s):
    return " ((%s)) "%("".join(["%02X"%ord(c) for c in s]))

def Unescape(s):
    q=[s[i:i+2] for i in xrange(0,len(s),2)]
    return "".join([chr(int(c,16)) for c in q])

def SplitTokens(ps):
    global Remap,NoRemap,UserSymbols,SymbolCount,RemapAll

    # handle escapes
    ps=re_dsc.sub(lambda s: Escape(s.group(0)),ps)
    ps=re_string.sub(lambda s: Escape(s.group(0)[:-1])+s.group(0)[-1], ps)
    ps=re_comment.sub("",ps)
    ps=ps.replace("\n"," ").replace("\r"," ").replace("\t"," ")

    # escape operators
    ps=ps.replace("/"," /")
    ps=ps.replace("<<"," [ ")
    for op in ('{','}','[',']','>>'):
        ps=ps.replace(op," %s "%op)

    # reduce blanks
    new_len=len(ps)
    old_len=-1
    while old_len!=new_len:
        old_len=new_len
        ps=ps.replace(64*" "," ")
        new_len=len(ps)
    for l in (32,16,8,4,2,2):
        ps=ps.replace(l*" "," ")

    # merge aggregates and kill redundancies
    for aggr in Aggregates:
        ps=ps.replace(" "+aggr.replace('_',' ')," "+aggr)
    for red in Redundancies:
        ps=ps.replace(" "+red,"")
   
    # collect tokens
    tokens=[]
    for token in ps.strip().split(' '):
        if token[:2]=='((': token=Unescape(token[2:-2])
        # handle preprocessor directives
        if token[:8]=="%#remap ":
            symbol=token[8:]
            if symbol=="all":
                RemapAll=True
            else:
                Remap[symbol]=None
        elif token[:10]=="%#noremap ":
            NoRemap[token[10:]]=None
            continue
        elif token[:9]=="%#symbol ":
            UserSymbols[token[9:]]=None
            Remap[token[9:]]=None
            continue
        else: # normal token
            try:
                # optimize floats
                dummy=float(token)
                if '.' in token:
                    while token[-1]=='0': token=token[:-1]
                    if token[-1]=='.': token=token[:-1]
                while len(token)>1 and token[0]=='0': token=token[1:]
            except ValueError:
                # count symbols
                if not token[0] in "%()[]{}<>":
                    symbol=token
                    if symbol[0]=='/': symbol=symbol[1:]
                    SymbolCount[symbol]=SymbolCount.get(symbol,0)+1
        tokens.append(token)
    return tokens


################################################################################
### CODE GENERATOR                                                           ###
################################################################################

class PSGenerator:
    def __init__(self):
        self.content=[]
        self.needspace=False
        self.linelength=0

    def put(self,token):
        if not token: return

        # handle multi-tokens
        if type(token)!=types.StringType:
            for t in token: self.put(t)
            return
        if token in Aggregates:
            for t in token.split('_'): self.put(t)
            return

        # comment -- direct pass-through
        if token[0]=='%':
            if self.linelength: token="\n%s"%token
            self.content.append("%s\n"%token)
            self.needspace=False
            self.linelength=0
            return

        # standard token
        needspace=not(token[0] in "/(){}[]<>")
        newlength=self.linelength+len(token)
        if self.needspace and needspace:
            newlength+=1
            if newlength>76:
                add="\n"
                newlength=len(token)
            else:
                add=" "
        else:
            add=""
        self.content.append(add+token)
        self.needspace=needspace or (token[0]=='/')
        self.linelength=newlength

    def __str__(self):
        if self.linelength: add="\n"
        else: add=""
        return "".join(self.content)+add


################################################################################
### OPTIMIZER                                                                ###
################################################################################

CharSetLength=len(CharSet)
MaxRemap=CharSet.index('g')*CharSetLength+CharSet.index('t')

def MakeSymbol(i):
    if i<CharSetLength: return CharSet[i]
    else: return MakeSymbol(i/CharSetLength)+MakeSymbol(i%CharSetLength)

def SetupRemap():
    global Remap,NoRemap,UserSymbols,SymbolCount,RemapAll
    
    # if RemapAll is selected, remap all symbols
    if RemapAll:
        SymbolCount["bind_def"]=999999
        for symbol in SymbolCount: Remap[symbol]=None

    # generate sorted symbol list
    symlist=[(key,SymbolCount[key],SymbolCount[key]*len(key)) for key in SymbolCount if not(key in NoRemap)]
    symlist.sort(lambda a,b: b[2]-a[2])
    Remap={}
    
    # generate remap list
    i=0
    after=MakeSymbol(i)
    for before,freq,lbefore in symlist:
        lafter=len(after)*freq
        if before in UserSymbols:
            feasible=lafter<lbefore
        else:
            feasible=(lafter+len(after)+len(before)+4)<lbefore
        if not feasible: continue
        Remap[before]=after
        i+=1
        after=MakeSymbol(i)

def DoRemap(ps,before,after,bind_def_remapped):
    if bind_def_remapped:
        bind_def=Remap["bind_def"]
    else:
        bind_def="bind_def"
    ps.put(("/%s"%after,'{',before,'}',bind_def))
    if before==bind_def: bind_def_remapped=True
    return bind_def_remapped

def GenerateRemapped(ps,tokens):
    global Remap,UserSymbols
    bind_def_remapped=False
    for token in tokens:
        if token[:8]=='%#remap ':
            # remap command
            symbol=token[8:]
            if symbol=="all":
                symlist=[item for item in Remap.items() if not(item[0] in UserSymbols)]
                symlist.sort(lambda a,b: cmp(a[1],b[1]))
                for before,after in symlist:
                    bind_def_remapped=DoRemap(ps,before,after,bind_def_remapped)
            else:
                if symbol in Remap:
                    bind_def_remapped=DoRemap(ps,symbol,Remap[symbol],bind_def_remapped)
        else:
            # standard token
            if token[0]=='/':
                token='/'+Remap.get(token[1:],token[1:])
            else:
                token=Remap.get(token,token)
            ps.put(token)


################################################################################
### MAIN AND TOOL FUNCTIONS                                                  ###
################################################################################

def Optimize(data):
    original=len(data)

    tokens=SplitTokens(data)
    f=PSGenerator()
    for t in tokens: f.put(t)
    stripped=len(str(f))

    SetupRemap()
    f=PSGenerator()
    GenerateRemapped(f,tokens)
    data=str(f)
    optimized=len(data)
    
    print "original: %d -- stripped: %d (%d%%) -- optimized: %d (%d%%/%d%%)"% \
          (original, stripped,stripped*100/original, optimized,optimized*100/original,optimized*100/stripped)
    return data


if __name__=="__main__":
    if not len(sys.argv) in (2,3):
        print "Usage:",sys.argv[0],"<source.ps> [<dest.out.ps>]"
        sys.exit(1)

    source=sys.argv[1]
    if len(sys.argv)>2:
        dest=sys.argv[2]
    else:
        dest=os.path.splitext(source)[0]+".out.ps"

    try:
        data=file(source,"r").read()
    except IOError:
        print "Error: cannot read input file `%s'!"%source        

    data=Optimize(data)

    try:
        file(dest,"wb").write(data)
    except IOError:
        print "Error: cannot write output file `%s'!"%dest
