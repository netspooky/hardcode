int real(int a)
{
  switch(a & 3)
  {
  case 0: return 3;
  case 1: return 5;
  case 2: return 7;
  case 3: return 11;
  }
}

int neggi(unsigned char a)
{
  if(!a)
    return 3;
  else if(!--a)
    return 5;
  else if(!--a)
    return 7;
  else if(!--a)
    return 11;
}
