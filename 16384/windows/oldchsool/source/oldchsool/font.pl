#!/opt/bin/perl5
##!/usr/bin/perl

sub encode_font()
{
   @lines=split("\n",$_[0]);
   $widths="";
   $offsets="";
   $crroff=0;
   for($i=0;$i<$#lines;$i+=8)
   {
      $byte=0;
      $x=0;
      do
      {
         $byte=0;
         for($j=0;$j<8;$j++)
         {
            if(substr($lines[$i+$j],$x,1) eq 'a') { $byte |= (1<<$j); }
         }
         if($byte!=0)
         {
            printf("0x%x,",$byte);
            $crroff++;
         }
         $x++;
      } while($byte!=0);
      $lengths.=sprintf("%d,",$x);
      print "0x00,\n";
   }
}

print "unsigned char font[]={\n";
&encode_font(<<EOD);
...
...
...
...
...
...
...

.aaaaa
.a..aa
.a..aa
aaaaaa
aa..aa
aa..aa
aa..aa

aaaaa.
aa..a.
aa..a.
aaaaaa
aa...a
aa...a
aaaaaa

.aaaaa
.a....
.a....
aa....
aa....
aa....
aaaaaa

aaaaa.
a...a.
a...a.
a...aa
a...aa
a...aa
aaaaaa

.aaaaa
.a....
.a....
aaaa..
aa....
aa....
aaaaaa

.aaaaa
.a....
.a....
aaaa..
aa....
aa....
aa....

.aaaaa
.a....
.a....
aa..aa
aa..aa
aa...a
aaaaaa

.a..aa
.a..aa
.a..aa
aaaaaa
aa..aa
aa..aa
aa..aa

.a
.a
.a
aa
aa
aa
aa

....a
....a
....a
...aa
...aa
aa.aa
aaaaa

a...aaa
a..aa..
a.aa...
aaaa...
aa.aa..
aa..aaa
aa..aaa

.a....
.a....
.a....
aa....
aa....
aa....
aaaaaa

.aaaaaaa
.a..a.aa
.a..a.aa
aa.aa.aa
aa.aa.aa
aa.aa.aa
aa.aa.aa

.aaaaa
.a..aa
.a..aa
aa..aa
aa..aa
aa..aa
aa..aa

.aaaaa
.a...a
.a...a
aa...a
aa...a
aa...a
aaaaaa

aaaaaa
a....a
a....a
aaaaaa
aa....
aa....
aa....

.aaaaa
.a...a
.a...a
aa...a
aa.aaa
aa..aa
aaaaaa

.aaaaa
.a....
.a....
aa....
aa....
aa....
aa....

.aaaaa
.a....
.a....
.aaaaa
....aa
....aa
aaaaaa

aaaaaa
...a..
...a..
..aa..
..aa..
..aa..
..aa..

a...aa
a...aa
a...aa
aa..aa
aa..aa
aa..aa
aaaaaa

aa..aa
aa..aa
aa..aa
aa..aa
.aa.a.
.aa.a.
.aaaa.

aa.aa.aa
aa.aa.aa
aa.aa.aa
aa.aa.aa
.a.aa.a.
.a.aa.a.
.aaaaaa.

aa..aaaa
aa..a...
aa..a...
aaaaaaaa
...aa..a
...aa..a
aaaaa..a

aa...a
aa...a
aa...a
aaaaaa
....aa
....aa
aaaaaa

aaaaaa
.....a
.....a
aaaaaa
aa....
aa....
aaaaaa

aa.aa.
......
aaaaa.
aa..a.
aaaaaa
aa..aa
aa..aa

.aa.aa 
......
.aaaaa
.a..aa
aa..aa
aa..aa
aaaaaa

....
....
....
aaaa
..aa
....
....
EOD
print "};\n\nchar font_lengths[]={$lengths};\n\n";
