#!/usr/bin/env python
import sys,os,re,types,string
from math import *

re_string=re.compile(r'".*"')
re_head_tail=re.compile(r'([^\s\(=,:]+)(.*)')
re_function_head=re.compile(r'([^\(]+)\(([^\)]*)\):?(.+)?')
re_var=re.compile(r'\$[^\s\(\),=:]+')
re_call=re.compile(r'([^\(]+)\((.*)\)(.*)$')
re_value=re.compile(r'(\$[^\s\(\),=:]+|[/&#].+|-?[0-9]+(\.[0-9]+)?)$')


class FileIterator:
    def __init__(self,filename):
        self.name=filename
        self.f=file(filename,"r")
        self.n=0
    def next(self):
        self.n+=1
        line=self.f.readline()
        if not line: raise EOFError
        return (str(self),line)
    def __str__(self):
        return "%s:%d"%(self.name,self.n)

class FileBuffer:
    def __init__(self):
        self.buf=[]
        self.pos="<unknown>"
    def write(self,s):
        #print s.rstrip()
        self.buf.append(s)
    def dump_stack(self,stack):
        self.write("\t%% %s\n"%(", ".join(stack)))
    def __str__(self):
        return "".join(self.buf)
    def __nonzero__(self):
        return (len(self.buf)!=0)
    def setpos(self,pos):
        self.pos=pos
    def getpos(self):
        return self.pos

class end_found(Exception): pass
class else_found(Exception): pass


def Error(position,message,is_error=True):
    global WarningCount,ErrorCount
    if position.__class__==FileBuffer: position=position.getpos()
    print "%s: %s: %s"%(("warning","error")[is_error],position,message)
    if is_error:
        ErrorCount+=1
        if ErrorCount>10:
            print "more than 10 errors, stopping now"
            sys.exit(1)
    else: WarningCount+=1

def StripParentheses(s):
    if not s: return ''
    s=s.strip()
    if s[:1]=='(' and s[-1:]==')': return StripParentheses(s[1:-1])
    return s

def SplitVarList(position,varlist):
    varlist=StripParentheses(varlist)
    if not varlist: return []
    l=map(string.strip,varlist.split(','))
    for v in l:
        if v[:1]!='$': Error(position,"`%s' is no variable"%v)
    return l

def TransformString(s):
    s=s.group(0)[1:-1]
    s=s.replace("\\\"","\"")
    s=s.replace("\\n","\n")
    s=s.replace("\\r","\r")
    s=s.replace("\\t","\t")
    s=s.replace("\\\\","\\")
    return "#"+"".join(["%02X"%ord(c) for c in s])

def UntransformString(coded):
    coded=coded[1:]
    s=""
    while coded:
        s+=chr(int(coded[:2],16))
        coded=coded[2:]
    s=s.replace("(","\\(")
    s=s.replace(")","\\)")
    return "(%s)"%s

Modules={}
Constants={}
ValidConstantIdentifiers="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopwrqstuvwxyz_0123456789"


################################################################################
### LINE-LEVEL PARSER                                                        ###
################################################################################

def ParseFile(filename,use_module=False):
    global Modules
    if use_module:
        if filename in Modules: return
        Modules[filename]=True
    try:
        f=FileIterator(filename)
    except IOError:
        Error(filename,"cannot open file")
        return []
    return ParseBlock(f,toplevel=True)


def ParseBlock(f,toplevel=False,else_ends=False):
    block=[]
    try:
        while True:
            stmt=ParseStatement(f)
            if stmt:
                if type(stmt)==types.ListType:
                    block.extend(stmt)
                else:
                    block.append(stmt)
    except end_found:
        if toplevel: Error(f,"unexpected `end' at toplevel")
    except EOFError:
        if not toplevel: Error(f,"unexpected end of file")
    except else_found:
        if not else_ends: Error(f,"unexpected `else'")
        block.append('else')
    return block


def ParseStatement(f):
    pos,line=f.next()
    line=re_string.sub(TransformString,line)
    line=line.strip()
    # handle multi-line comments
    if line[:3]=="%--":
        while True:
            line=line.split("--%",1)
            if len(line)>1:
                line=line[1].strip()
                break
            else:
                pos,line=f.next()
    # strip comments
    line=line.split('%',1)[0]
    if not line: return None
    
    # substitute constants
    for const in Constants:
        while True:
            p=line.find(const)
            if p<0: break
            if p>0 and (line[p-1] in ValidConstantIdentifiers): break
            q=p+len(const)
            if q<len(line) and (line[q] in ValidConstantIdentifiers): break
            line=line[:p]+Constants[const]+line[q:]
    
    # split into head and tail
    m=re_head_tail.match(line)
    if m: head,tail=(m.group(1).lower(),m.group(2).strip())
    else: head,tail=('',line)

    # dispatch special lines
    if head=="include":  return ParseFile(tail,False)
    if head=="use":      return ParseFile(tail,True)
    if head=="const":    return ParseConstant(f,tail)
    if head=="end":      raise end_found
    if head=="else":     raise else_found
    if head=="raw":      return ParseRaw(f,tail)
    if head=="function": return ParseFunction(f,tail)
    if head=="if":       return ParseIf(f,tail)
    if head=="for":      return ParseFor(f,tail)

    # normal line
    item={'type':'let', 'pos':str(f)}
    if '=' in line:
        vout,line=line.split('=',1)
        item['write']=SplitVarList(f,vout)
    item['read']=re_var.findall(line)
    item['expr']=ParseExpression(f,StripParentheses(line))
    return item


def ParseRaw(f,spec):
    item={'type':'raw', 'pos':str(f), 'content':""}
    if ':' in spec:
        expr,vout=spec.split(':',1)
        item['write']=SplitVarList(f,vout)
    elif spec:
        expr=spec
    else:
        expr=None
    if expr:
        item['read']=re_var.findall(expr)
        item['expr']=ParseExpression(f,StripParentheses(expr))
    while True:
        pos,line=f.next()
        if line.strip().split('%',1)[0]=="end": break
        item['content']+=line
    return item


def ParseFunction(f,spec):
    item={'type':'func', 'pos':str(f)}
    m=re_function_head.match(spec)
    if not m:
        Error(f,"invalid function header syntax")
        return item
    name,vin,vout=m.groups()
    item['name']=name.strip()
    item['in']=SplitVarList(f,vin)
    item['out']=SplitVarList(f,vout)
    item['body']=ParseBlock(f)
    item['body'].append({'type':'return', 'pos':str(f), 'read':item['out']})
    return item


def ParseIf(f,spec):
    item={'type':'if', 'pos':str(f)}
    if ':' in spec:
        expr,vout=spec.split(':',1)
        item['write']=SplitVarList(f,vout)
    else:
        expr=spec
        item['write']=[]
    item['expr']=ParseExpression(f,StripParentheses(expr))
    item['read']=re_var.findall(expr)
    item['if']=ParseBlock(f,else_ends=True)
    if len(item['if']) and item['if'][-1]=='else':
        del item['if'][-1]
        item['else']=ParseBlock(f)
        item['else'].append({'type':'return', 'pos':str(f), 'read':item['write']})
    item['if'].append({'type':'return', 'pos':str(f), 'read':item['write']})
    return item


def ParseFor(f,spec):
    item={'type':'for', 'pos':str(f)}
    expr=ParseExpression(f,StripParentheses(spec))
    if len(expr)!=4: Error(f,"wrong number of arguments in for statement")
    if expr[0][0]!='$': Error(f,"`%s' is not a control variable"%expr[0])
    item['var']=expr[0]
    item['expr']=expr[1:]
    item['read']=re_var.findall(spec.split(',',1)[-1])
    item['body']=ParseBlock(f)
    return item


def ParseConstant(f,line):
    global Constants
    try:
        name,expr=map(string.strip,line.split('=',1))
    except ValueError:
        Error(f,"syntax error")
        return
    try:
        Constants[name]=str(eval(expr))
    except Exception, e:
        Error(f,str(e))


################################################################################
### EXPRESSION-LEVEL PARSER                                                  ###
################################################################################

def ParseExpression(f,line):
    if not line:
        # it's the empty expression
        return []
    # check for parameter list
    res=[]
    level=0
    start=0
    for i in xrange(len(line)):
        c=line[i]
        if c=='(':
            level+=1
        elif c==')':
            level-=1
            if level<0:
                Error(f,"unbalanced parenthesis in expression `%s'"%line)
                return []
        elif c==',' and level==0:
            res.append(ParseValue(f,line[start:i]))
            start=i+1
    if level!=0:
        Error(f,"unbalanced parenthesis in expression `%s'"%line)
        return res
    res.append(ParseValue(f,line[start:]))
    return res

def ParseValue(f,line):
    line=line.strip()
    m=re_call.match(line)
    if m:
        # it's a function call
        if m.group(3):
            Error(f,"invalid characters `%s' after call to function `%s'"% \
                    (m.group(3),m.group(1)))
        return [m.group(1)+'()']+ParseExpression(f,m.group(2))
    # it's a value
    if not re_value.match(line):
        Error(f,"unknown expression or value `%s'"%line)
    return line



################################################################################
### CODE GENERATION                                                          ###
################################################################################


def GenerateBlock(f,tree,fixed=[],stack=[],post=None):
    if not tree: return stack
    fixedvars=dict([(var,True) for var in fixed])
    stack=fixed+stack
    for i in xrange(len(tree)):
        node=tree[i]
        f.setpos(node.get('pos',"<unknown>"))
        if f or (tree[0]['type']!='raw'):
            f.write("%% -- %s\n"%f.getpos())

        # handle function definition
        if node['type']=='func':
            f.write("%%#symbol %s\n/%s {\n"%(node['name'],node['name']))
            vin=node.get('in',[])
            if vin: f.dump_stack(vin)
            GenerateBlock(f,node['body'], stack=vin, post=node.get('out',[]))
            f.write("} bind def\n")
            continue

        # determine variables that have to be kept on-stack
        keep=fixedvars.copy()
        vin=node.get('read',[])
        if vin:
            DetermineUsedVariables(vin,tree,keep,i+1,i)
            # also keep variables that are used multiple times
            once={}
            for var in vin:
                if var in once: keep[var]=True
                else: once[var]=True

        # evaluate expression
        expr=node.get('expr',None)
        if expr:
            while len(expr)==1 and type(expr[0])==types.ListType: expr=expr[0]
            stack=RemoveResult(AddToStack(f,stack,keep,expr),expr)
        vout=node.get('write',[])

        # assign expression result to variables
        if node['type']=='let':
            if vout:
                stack.extend(node['write'])
                f.dump_stack(stack)
            elif expr:
                # no return value -> ignore dummy results left on stack
                f.dump_stack(stack)

        # handle raw expression
        if node['type']=='raw':
            f.write(node['content'])
            stack.extend(vout)
            f.dump_stack(stack)

        # handle for expression
        if node['type']=='for':
            f.write("{\n")
            var=[node['var']]
            f.dump_stack(stack+var)
            GenerateBlock(f,node['body'], fixed=stack, stack=var, post=[])
            f.write("} for\n")

        # handle if expression
        if node['type']=='if':
            f.write("{\n")
            f.dump_stack(stack)
            st_if=GenerateBlock(f,node['if'], fixed=stack, stack=[], post=vout)
            if 'else' in node:
                f.write("} {\n")
                f.dump_stack(stack)
                st_else=GenerateBlock(f,node['else'], fixed=stack, stack=[], post=vout)
                f.write("} ifelse\n")
                if st_if!=st_else:
                    Error(f,"if and else path return stacks don't match")
            else:
                f.write("} if\n")
            stack=st_if

        # remove unused variables from stack
        used=fixedvars.copy()
        DetermineUsedVariables(stack,tree,used,i+1,i+1)
        if (node['type']=='return') and post:
            used.update(dict([(var,True) for var in post]))
        stack=KillVars(f,stack,[obj for obj in stack if not used.get(obj,False)])

    # reorder stack to match post-function order
    if post!=None and (stack!=post):
        stack=KillVars(f,stack,[obj for obj in stack \
            if not(fixedvars.get(obj,False)) and not(obj in post)])
        stack=SetStackTail(f,stack,post)
        if stack!=fixed+post:
            Error(f,"end-of-block stack does not match reference")
    return stack


def DetermineUsedVariables(varset,tree,used,rstart=0,wstart=0):
    for j in xrange(min(rstart,wstart),len(tree)):
        node=tree[j]
        # variables that are read soon are USED
        if j>=rstart:
            check=node.get('read',[])
            for var in varset:
                if not(var in used) and (var in check):
                    used[var]=True
        # descent into subblocks
        if ('body' in node) and (node['type']!='func'):
            DetermineUsedVariables(varset,node['body'],used)
        if 'if'   in node: DetermineUsedVariables(varset,node['if'],  used)
        if 'else' in node: DetermineUsedVariables(varset,node['else'],used)
        # variables that are modified soon are NOT used
        if j>=wstart:
            check=node.get('write',[])
            for var in varset:
                if not(var in used) and (var in check):
                    used[var]=False
    return used


def RemoveResult(stack,expr):
    if not expr: return stack
    if expr[0][-2:]=='()': return stack[:-1]
    else: return stack[:-len(expr)]


def FlattenFunction(tree):
    if not tree:
        return ""
    if type(tree)!=types.ListType:
        return tree
    if tree[0][-2:]=='()':
        return "%s(%s)"%(tree[0][:-2],FlattenFunction(tree[1:]))
    return ",".join(map(FlattenFunction,tree))


def PushPop(f,stack,count,replace=None):
    remain=len(stack)-count
    if remain<0: Error(f,"stack underflow")
    if not replace:
        stack=stack[:remain]
    elif type(replace)==types.ListType:
        stack=stack[:remain]+replace
    else:
        stack=stack[:remain]+[replace]
    f.dump_stack(stack)
    return stack


def MoveToFront(f,stack,obj,copy=False):
    realindex=len(stack)-1
    while (realindex>=0) and (stack[realindex]!=obj): realindex-=1
    if realindex<0:
        Error(f,"can't find object named `%s' on the stack"%obj)
        return stack
    index=len(stack)-realindex
    if copy:
        if index==1: f.write("dup\n")
        else: f.write("%d index\n"%(index-1))
    else:
        if index==1: return stack
        if index==2: f.write("exch\n")
        else: f.write("%d -1 roll\n"%index)
        del stack[realindex]
    stack.append(obj)
    f.dump_stack(stack)
    return stack


def SetStackTail(f,stack,tail):
    if stack[-len(tail):]==tail: return stack
    for obj in tail:
        MoveToFront(f,stack,obj)
    return stack


def KillVars(f,stack,varlist):
    varlist.reverse()
    for obj in varlist:
        stack=MoveToFront(f,stack,obj)
        f.write("pop\n")
        if stack: del stack[-1]
        f.dump_stack(stack)
    return stack


def AddToStack(f,stack,keep,top):
    if not top: return stack
    # single function call recursion
    if top[0][-2:]=='()':
        stack=AddToStack(f,stack,keep,top[1:])
        f.write("%s\n"%top[0][:-2])
        stack=PushPop(f,stack,len(top)-1,FlattenFunction(top))
        return stack
    # generic reordering
    for item in top:
        if type(item)==types.ListType:
            # resolve function call
            assert item[0][-2:]=='()'
            stack=AddToStack(f,stack,keep,item[1:])
            f.write("%s\n"%item[0][:-2])
            stack=PushPop(f,stack,len(item)-1,FlattenFunction(item))
        elif item[:1]=='$':
            # get variable
            stack=MoveToFront(f,stack,item,keep.get(item,False))
        else:
            # literal value -- push onto stack
            literal=item
            if literal[:1]=='&': literal=literal[1:]
            elif literal[:1]=='#': literal=UntransformString(literal)
            f.write("%s\n"%literal)
            stack=PushPop(f,stack,0,item)
    return stack


################################################################################
### MAIN AND TOOL FUNCTIONS                                                  ###
################################################################################

KeySortOrder=['type','name','var','in','out','write','read','expr','pos']
def KeyIndex(key):
    try: return "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"[KeySortOrder.index(key)]
    except ValueError: return key

def DumpTree(tree,level=0):
    space="\t"*level
    level+=1
    for node in tree:
        keys=[key for key in node.iterkeys() if not key in ('body','if','else','content')]
        keys.sort(lambda a,b: cmp(KeyIndex(a), KeyIndex(b)))
        print space,
        for key in keys:
            print "%s=%s"%(key,node[key]),
        print
        if 'body' in node: DumpTree(node['body'],level)
        if 'if'   in node: DumpTree(node['if'],  level)
        if 'else' in node: DumpTree(node['else'],level)


def Compile(filename):
    global WarningCount,ErrorCount
    WarningCount=0
    ErrorCount=0
    Tree=ParseFile(filename)
    if ErrorCount:
        print "%d error(s), %d warning(s) during parsing, aborting"%(ErrorCount,WarningCount)
        sys.exit(1)
    elif WarningCount:
        print "%d warning(s) during parsing"%WarningCount
        WarningCount=0

    Output=FileBuffer()
    if GenerateBlock(Output,Tree):
        Error("toplevel","script leaves variables on stack",is_error=False)
    if ErrorCount:
        print "%d error(s), %d warning(s) during code generation, aborting"%(ErrorCount,WarningCount)
    elif WarningCount:
        print "%d warning(s) during code generation"%WarningCount
    return str(Output)



if __name__=="__main__":
    if not len(sys.argv) in (2,3):
        print "Usage:",sys.argv[0],"<source.pp> [<dest.ps>]"
        sys.exit(1)

    source=sys.argv[1]
    if len(sys.argv)>2:
        dest=sys.argv[2]
    else:
        dest=os.path.splitext(source)[0]+".ps"

    out=Compile(source)

    try:
        file(dest,"w").write(out)
    except IOError:
        Error("output","cannot write output file `%s'"%dest)
