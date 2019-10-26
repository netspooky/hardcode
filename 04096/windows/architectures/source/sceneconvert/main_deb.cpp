#include <windows.h>
#include <mmsystem.h>
#include <stdio.h>
#include <string>
#include <vector>

using namespace std;

vector<string> thesource;

std::string getNthElement(const string &input, int elem)
{
	int stringpos = 0;
	while (input[stringpos] != '{')
		stringpos++;

	stringpos++;

	int klammer = 0;
	int currentElement = 0;
	while (currentElement != elem)
	{
		if (input[stringpos] == '(')
			klammer++;
		if (input[stringpos] == ')')
			klammer--;

		char here = input[stringpos];
		if (here == ',' && klammer == 0)
			currentElement++;
		if (here == '}')
			return "";
		stringpos++;
	}
	std::string ret;

	klammer = 0;
	while (input[stringpos] != ',' && input[stringpos] != '}' || klammer != 0)
	{
		if (input[stringpos] == '(')
			klammer++;
		if (input[stringpos] == ')')
			klammer--;

		ret += input[stringpos];
		stringpos++;
	}
	return ret;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	FILE *in = fopen("scenessource.cpp","r");
	if (!in)
		return -1;
	while (!feof(in))
	{
		char buffer[1024];
		if (fgets(buffer,1024,in) != 0)
			thesource.push_back(string(buffer));
	}
	fclose(in);

	FILE *out = fopen("scenescompiled.h","w");
	int elem = 0;
	while(1)
	{
		if (getNthElement(thesource[0],elem) == "")
			break;
		string typ = "float";
		if (elem == 7)
			typ = "int";
		//fprintf(out,"#pragma data_seg(\"dataseg%d\")\n",elem);
		fprintf(out,"%s sceneElement%d[] = {\n",typ.c_str(),elem);
		for (int i = 0; i < (int)thesource.size(); ++i) 
		{
			if (elem == 0)
			{
				float current = atof(getNthElement(thesource[i],elem).c_str());
				float last = 0.f;
				if (i != 0)
					last = atof(getNthElement(thesource[i-1],elem).c_str());
				float delta = current-last;
				fprintf(out,"  %ff,\n",delta);
			}
			else
				fprintf(out,"  %s,\n",getNthElement(thesource[i],elem).c_str());
		}
		fprintf(out,"};\n");
		elem++;
	}
	fclose(out);
	return 0;
}
