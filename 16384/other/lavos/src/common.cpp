#include "common.hpp"

float common::cclampf(float op, float min, float max)
{
  return common::cfmaxf(common::cfminf(op, max), min);
}

float common::cclamp1f(float op)
{
  return cclampf(op, -1.0f, 1.0f);
}

