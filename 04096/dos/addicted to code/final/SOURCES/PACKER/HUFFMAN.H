
int maxsymbol;		// maximum number of symbols ( lastsymbol )	

class freqnode {
public:
	int num;
	int bits;
	int code;
	};
///////////////////////////////////////////////////////////////////////////////
class _huffnode {
public:
  _huffnode *left,*rite;
  int code;
};
///////////////////////////////////////////////////////////////////////////////
class hufftree {
private:
  int 		x;			// useful variable
  int		numnodes;		// number of used nodes in freq table
  int		maxnode;		// last node number 
  int		treenodes;		// number of tree nodes
  int		bitlimit;		// limit for number of bits for code
public: 
  freqnode	*fqtab;			// frequency table
  _huffnode 	*tree;			// entropy code tree

  hufftree(int _maxnode);		// constructor (maxnode)
  ~hufftree();				// destructor
  void make_codes(int _bitlimit);	// prepare codes (only by bit lengths)
  void make_tree();			// prepare tree (for decompression)
//  int read_code(int )
};
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
hufftree::hufftree(int _maxnode) {
  maxnode = _maxnode;
  fqtab = new freqnode [maxnode];
  for (x=0; x<maxnode; x++) {
    fqtab[x].num = 0;
    fqtab[x].bits = 0;
    }
  tree = NULL;
  treenodes = 0;
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
hufftree::~hufftree() {
  if (fqtab) delete [] fqtab;
  if (tree) delete [] tree;
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
void hufftree::make_codes(int _bitlimit) {
  bitlimit = _bitlimit;
  if (fqtab) {
    numnodes = 0;
    for (x=0; x<maxnode; x++) if (fqtab[x].num) numnodes++;
    }
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
/*
int hufftree::read_code() {
_huffnode *k;
  k = tree;
  if (k) {
    while(k->code == -1) {
      //readbit();
      //if (bit) k = k->left;
      //else k = k->rite;
    }
    return k->code;
  }
}
*/
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
void hufftree::make_tree() {
_huffnode *k;
int i;
  tree = new _huffnode [maxnode*2];
  k = tree;

  k->left = k->rite = NULL;
  k->code = -1;
  treenodes++;
  for (x=0; x<maxnode; x++) if (fqtab[x].bits) {
    for (i=0; i<fqtab[x].bits; i++) 
      if (fqtab[x].code && (1 << (fqtab[x].bits-1-i))) {
        if (k->left) k = k ->left;
        else {
          k->left = &(tree[treenodes++]);
          k = k->left;
          k->left = k->rite = NULL;
          k->code = -1;
          }
        } 
      else {
        if (k->rite) k = k->rite;
        else {
          k->rite = &(tree[treenodes++]);
          k = k->rite;
          k->left = k->rite = NULL;
          k->code = -1;
          }
        }
  k->code = x;
  }
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
void mkhuffcodes(freqnode *n) {
  int code = 0;
  for (int x=1; x<16; x++) {
    code <<= 1;
    for (int m=0; m<maxsymbol; m++)
      if (n[m].bits == x) n[m].code = code++;
  }
}
///////////////////////////////////////////////////////////////////////////////
class huffnode {
public:
	huffnode 	*next;
	huffnode 	*prev;
	huffnode	*dnode;
	static huffnode *first;
	static huffnode *last;
	static unsigned	amount;	
	huffnode();
	~huffnode();
	void hide();
  	void kill();

	int		symbol;
	unsigned	num;
	};

unsigned huffnode::amount = 0;
huffnode *huffnode::first = NULL;
huffnode *huffnode::last = NULL;

huffnode::huffnode() {
	if (!amount++) first = this;
	prev = last;
	last = this;
	next = NULL;
	prev->next = this;
	dnode = NULL;
}

huffnode::~huffnode() {
	if (!--amount) first = NULL;
	if (next) next->prev = prev;
	if (prev) prev->next = next;
	if (first==this) first = next;
	if (last==this) last = prev;
} 

void huffnode::hide() {
	if (!--amount) first = NULL;
	next->prev = prev;
	prev->next = next;
	if (first==this) first = next;
	if (last==this) last = prev;
} 

void huffnode::kill() {
	if (dnode) dnode->kill();
	this->~huffnode();
}	
///////////////////////////////////////////////////////////////////////////////

void		LimitTree(freqnode *n,int bitlimit);
unsigned	huffsize;
unsigned	lastsymbol,symbolsused;
huffnode	*hufflist;

void DoHuffman(freqnode *n,int bitlimit,int show) {
int x;        

  symbolsused = 0;
  for (x=0; x<maxsymbol; x++) if (n[x].num) {
	lastsymbol = x+1;
	symbolsused++;
	}

  if (show) {
    cout << "Huffman entry info (lastsymbol,used) : ";
    cout << lastsymbol << "   " << symbolsused << endl;
    }
  
  hufflist = new huffnode [symbolsused];

  int i = 0;
  for (x=0; x<lastsymbol; x++) if (n[x].num) {
    hufflist[i].symbol = x;
    hufflist[i].num = n[x].num;
    hufflist[i].dnode = NULL;
    i++;
    }
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////



	huffnode *h,*x1,*x2,*nn;
	unsigned numm;



while (h->amount > 1) {	
	numm = 0x7FFFFFFF;
	for (h=h->first; h; h=h->next) if (h->num<=numm) {
		numm = h->num;
		x1=h;
		}
	x1->hide();

	numm = 0x7FFFFFFF;
	for (h=h->first; h; h=h->next) if (h->num<=numm) {
		numm = h->num;
		x2=h;
		}
	x2->hide();

	nn = new huffnode;
	x1->dnode = nn;
	x2->dnode = nn;
	nn->num = (x1->num + x2->num);
	}
///////////////////////////////////////////////////////////////////////////////

  for (x=0; x<symbolsused; x++) {
	unsigned codelen = 0;
	for (h=&(hufflist[x]); h->dnode; h=h->dnode) codelen++;
	n[hufflist[x].symbol].bits = codelen;
	}	
  LimitTree(n,bitlimit);

  huffsize = 0;
  for (x=0; x<lastsymbol; x++) 
    if (n[x].num) huffsize+=(n[x].num * n[x].bits);

  if (show) cout << "Huffman coded size : " << (int)(huffsize / 8)+1 << endl;

  huffnode *hhh;
  for (hhh=hhh->first; hhh; hhh=hhh->next) hhh->~huffnode();
  
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
void LimitTree(freqnode *n,int bitlimit) {
freqnode *nd;
freqnode **limitlist;
int	 to_limit;
int	 maxbits,max,max2;

int	 numnodes;
int	 x,t,tl;
int	 least;
int	 lessbits,lessfreq;

  numnodes = lastsymbol;
  if (numnodes > (1 << bitlimit)) {
     cout << "Error while limiting tree 0 !" << endl;
     return;
     }

  t = 0;
  for (x=0; x<lastsymbol; x++) if (n[x].bits>bitlimit) {
     t = 1;
     break;
     }
  if (t!=1) return;

  limitlist = new freqnode* [numnodes];
///////---------------------------------------------
  while(t==1) {

  to_limit = 0;
  for (x=0; x<numnodes; x++)
    if (n[x].bits>bitlimit) limitlist[to_limit++] = &n[x];
  if (to_limit == 0) break;

  max = 0;
  max2 = 0;
  maxbits = bitlimit+1;
  for (x=0; x<to_limit; x++)
    if (limitlist[x]->bits >= maxbits) {
      maxbits = limitlist[x]->bits;
      max2 = max;
      max = x;
      }

  least = 0;
  lessbits = 1;
  lessfreq = 0x7FFFFFFF;
  for (x=0; x<numnodes; x++) {
    nd = &(n[x]);
      if (nd->bits <= (bitlimit-1))
        if (nd->bits >=lessbits) {
          if ((nd->bits == lessbits)&&(lessfreq < nd->num)) continue;
	    lessfreq = nd->num;
	    lessbits = nd->bits;
  	    least = x;
            }   
        }
  n[least].bits++;
  limitlist[max]->bits = n[least].bits;
  limitlist[max2]->bits--;

  }
  delete [] limitlist;
////////////////////////////////////
}
