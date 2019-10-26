
macro pushdl double
{
fild qword [double]
sub esp,8
fstp qword [esp]
}
macro glpushv GLfloatVar
{
push dword [GLfloatVar+4]
push dword [GLfloatVar]
}
macro glpush GLfloatVar
{
name = GLfloatVar
virtual at 0
dq GLfloatVar
load name#.l dword from 0
load name#.h dword from 4
end virtual
if name.h=0
push ebx
else
push dword name.h
end if
if name.l=0
push ebx
else
push dword name.l
end if
}
macro glcall procedure,[arg]
{
reverse
if arg eqtype 1.0f
glpush arg
else
addr=arg
glpushv addr
end if
common
call dword [procedure]
}
macro memcall procedure,[arg]
{
common
if ~ arg eq
reverse
pushd arg
common
call dword [procedure]
else
call dword [procedure]
end if
}