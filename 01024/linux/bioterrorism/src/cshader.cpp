#include <iostream>
#include <map>
using namespace std;
int main(int argc, char* argv[]) {
	map<string,string> replace;
	for(int i=1; i+1<argc; i+=2)
		replace[argv[i]] = argv[i+1];
	string s;
	string src;
	while(getline(cin,s)) {
		src += s+'\n';
	}
	bool pword=0;
	string res;
	for(size_t i=0; i<src.size(); ++i) {
		char c = src[i];
		if (isspace(c)) continue;
		if (isalpha(c)) {
			if (pword) res+=' ';
			int j=i;
			while(isalnum(src[j])) {
				++j;
			}
			string wd = src.substr(i,j-i);
//			cout<<wd<<'\n';
			if (replace.count(wd)) res += replace[wd];
			else res+=wd;
			i=j-1;
			pword=1;
			continue;
		}
		pword=0;
		if (c=='/' && src[i+1]=='/') {
			while(i<src.size() && src[i]!='\n') ++i;
			continue;
		} else if (c=='/' && src[i+1]=='*') {
			while(i+1<src.size() && !(src[i]=='*' && src[i+1]=='/')) ++i;
			++i;
			continue;
		}
		res += c;
	}
	cout<<res;
	cout.flush();
}
