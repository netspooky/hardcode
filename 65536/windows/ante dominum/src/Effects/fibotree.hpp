#ifndef _FIBOTREE_HPP_
#define _FIBOTREE_HPP_

#include "../stuff.hpp"

class FiboTreeItem
{
public:

	FiboTreeItem() {};
	~FiboTreeItem() {};

	Vector v1;
	Vector v2;
	int generation;

	float starttime;
	float endtime;
};

class FiboTree
{
public:

	void draw(float aika, float alpha);

	float starttime, endtime;
	Lista *tree;

};

void fibotree(float aika);
void fibotree_init();
void fibotree_free();
void fibotree_recurse(Lista *list, Vector &sourcepoint, int depth, int maxdepth);

#endif 
