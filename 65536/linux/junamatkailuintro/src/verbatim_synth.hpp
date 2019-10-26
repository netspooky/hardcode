#ifndef VERBATIM_SYNTH_HPP
#define VERBATIM_SYNTH_HPP

#include "verbatim_realloc.hpp"

/** \file File used to include all synth code verbatim.
 *
 * To be used when compiling into actual, small binary version. Otherwise not necessary, and the normal synth
 * headers should be used.
 */
#include "common.cpp"
#include "delay.cpp"
#include "env_gen.cpp"
#include "filter.cpp"
#include "oscillator.cpp"
#include "poly_handler.cpp"
#include "reverb.cpp"
#include "synth.cpp"
#include "voice.cpp"

#endif
