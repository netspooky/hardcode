
#ifndef __VIEW_H__
#define __VIEW_H__

#include <vector>

struct View {

	View( int _left, int _right, int _bottom, int _top );

	float	getAspect() const;

	int		left;
	int		right;
	int		bottom;
	int		top;
};

typedef std::vector<View>	viewList;

#endif