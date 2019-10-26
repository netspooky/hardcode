#include <iostream>
#include <fstream>
#include <boost/algorithm/string.hpp> 
using namespace std;

string str[][2] = {
    {" ) ", ")"},
    {" ( ", "("},
    {" = ", "="},
    {"} ", "}"},
    {" {", "{"},
    {" + ", "+"},
    {" - ", "-"},
    {" / ", "/"},
    {" * ", "*"},
    {"; ", ";"},
    {" , ", ","},
    {", ", ","},
    {" ,", ","},
    {" += ", "+="},
    {" -= ", "-="},
    {" *= ", "*="},
    {" /= ", "%="},
    {" < ", "<"},
    {" > ", ">"},
};

int main() {
    string file;
    ifstream shaders("shaders.txt");

    while (shaders >> file) {
        ifstream in((file + ".glsl").c_str());

        cout << "const char* " << file << " = " << endl;
        while (in.good()) {
            string line;
            getline(in, line);

            // Remove comments
            size_t comment = line.find("//");
            if (comment != string::npos) line.erase(line.begin() + comment, line.end());

            // Trim whitespace
            boost::trim(line);

            // Skip if no line left
            if (!line.length()) continue;

            // #-directives require newline
            if (line[0] == '#') line.append("\\n");

            // Remove inline whitespace
            for (int i = 0; i < 19; ++i) boost::replace_all(line, str[i][0], str[i][1]);

            cout << "\"" << line << "\"" << endl;
        }
        cout << ";" << endl << endl;
    }

    return 0;
}
