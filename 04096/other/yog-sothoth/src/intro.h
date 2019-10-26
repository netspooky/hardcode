#ifndef INTRO_INTRO_H
#define INTRO_INTRO_H

#if defined(HAVE_INTTYPES_H)
#include <inttypes.h>
#elif defined(HAVE_STDINT_H)
#include <stdint.h>
#else // default
#include <stdint.h>
#endif

#if defined(USE_LD)

#if defined(__cplusplus)
extern "C" {
#endif

/** \brief Audio writing callback.
 *
 * @param data Raw audio data.
 * @param size Audio data size (in samples).
 */
void write_audio_callback(uint8_t *data, unsigned size);

/** \brief Image writing callback.
 *
 * @param screen_w Screen width.
 * @param screen_h Screen height.
 * @param idx Frame index to write.
 */
void write_frame_callback(int screen_w, int screen_h, unsigned idx);

/** Intro call to make.
 *
 * @param screen_w Window width.
 * @param screen_h Window height.
 * @param flag_developer True to turn on developer mode.
 * @param flag_fullscreen Enable fullscreen?
 * @param flag_record Do not play intro normally, record it to disk instead.
 */
int intro(int screen_w, int screen_h, uint8_t flag_developer, uint8_t flag_fullscreen, uint8_t flag_record);

#if defined(__cplusplus)
}
#endif

#endif

#endif
