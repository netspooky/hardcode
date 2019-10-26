#ifndef SYNTH_VERBATIM_HPP
#define SYNTH_VERBATIM_HPP

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
#include "synth.cpp"
#include "voice.cpp"

#endif
