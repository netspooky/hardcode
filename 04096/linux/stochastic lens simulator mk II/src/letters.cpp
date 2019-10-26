#include <iostream>
#include <fstream>
#include <map>
#include <string>
using namespace std;

const char *a = 
" xx "
"x  x"
"xxxx"
"x  x"
"x  x";

const char *b = 
"xxx "
"x  x"
"xxx "
"x  x"
"xxx ";

const char *c =
" xx "
"x  x"
"x   "
"x  x"
" xx ";

const char *d = 
"xxx "
"x  x"
"x  x"
"x  x"
"xxx ";

const char *e =
"xxxx"
"x   "
"xxx "
"x   "
"xxxx";

const char *f = 
"xxxx"
"x   "
"xxx "
"x   "
"x   ";

const char *g =
" xx "
"x   "
"x xx"
"x  x"
" xx ";

const char *h =
"x  x"
"x  x"
"xxxx"
"x  x"
"x  x";

const char *i =
" x  "
" x  "
" x  "
" x  "
" x  ";

const char *j =
"   x"
"   x"
"   x"
"x  x"
" xx ";

const char *k =
"x  x"
"x x "
"xx  "
"x x "
"x  x";

const char *l =
"x   "
"x   "
"x   "
"x   "
"xxxx";

const char *m =
"x  x"
"xxxx"
"x  x"
"x  x"
"x  x";

const char *n =
"x  x"
"xx x"
"x xx"
"x  x"
"x  x";

const char *o =
" xx "
"x  x"
"x  x"
"x  x"
" xx ";

const char *p =
"xxx "
"x  x"
"xxx "
"x   "
"x   ";

const char *q =
" xx "
"x  x"
"x  x"
"x x "
" x x";

const char *r =
"xxx "
"x  x"
"xxx "
"x  x"
"x  x";

const char *s =
" xxx"
"x   "
"xxxx"
"   x"
"xxxx";

const char *t =
"xxxx"
" x  "
" x  "
" x  "
" x  ";

const char *u = 
"x  x"
"x  x"
"x  x"
"x  x"
" xx ";

const char *v =
"x  x"
"x  x"
"x  x"
" x x"
"  x ";

const char *w =
"x  x"
"x  x"
"x  x"
"xxxx"
"x  x";

const char *x =
"x  x"
"x  x"
" xx "
"x  x"
"x  x";

const char *y = 
"x  x"
"x  x"
" xx "
"  x "
"  x ";

const char *z =
"xxxx"
"   x"
" xx "
"x   "
"xxxx";

const char *huuto = 
" x  "
" x  "
" x  "
"    "
" x  ";

const char *space = 
"    "
"    "
"    "
"    "
"    ";

map<char,const char*> _letters = {
    {' ',space},
    {'a',a},
    {'b',b},
    {'c',c},
    {'d',d},
    {'e',e},
    {'f',f},
    {'g',g},
    {'h',h},
    {'i',i},
    {'j',j},
    {'k',k},
    {'l',l},
    {'m',m},
    {'n',n},
    {'o',o},
    {'p',p},
    {'q',q},
    {'r',r},
    {'s',s},
    {'t',t},
    {'u',u},
    {'v',v},
    {'w',w},
    {'x',x},
    {'y',y},
    {'z',z},
    {'!',huuto},
};

int numerify(char let) {
    if (!_letters.count(let)) return 0;

    const char *mask = _letters[let];

    int accum = 0;
    for (int yy = 0; yy < 20; yy += 4) {
        for (int xx = 0; xx < 4; xx += 1) {
            if (mask[yy+xx] != ' ') {
                accum |= 1 << (yy+xx);
            }
        }
    }
    return accum;
}


int main() {
    ifstream greetings("greetings.txt");
    string word;

    cout << _letters.size() << endl;
    for (auto i = _letters.begin(); i != _letters.end(); ++i) {
        cout << numerify(i->first) << ",";
    }
    cout << endl << endl;

    while (greetings.good()) {
        getline(greetings, word);
        if (!word.length()) continue;
        
        cout << word << "(" << word.length() << ") : ";

        for (auto ii = word.begin(); ii != word.end(); ++ii) {
            cout << distance(_letters.begin(), _letters.find(*ii)) << ",";
        }
        cout << endl;
    }
};
