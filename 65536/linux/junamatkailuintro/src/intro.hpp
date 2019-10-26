#ifndef INTRO_HPP
#define INTRO_HPP

#if defined(HAVE_INTTYPES_H)
#include <inttypes.h>
#elif defined(HAVE_STDINT_H)
#include <stdint.h>
#else // default
#include <stdint.h>
#endif

#if defined(USE_LD)

/** \brief Get default resolution.
 *
 * \return Default vertical resolution.
 */
extern unsigned get_default_resolution();

/** \brief Set developer mode (global flag).
 *
 * \param flag_developer Developer mode state.
 */
extern void set_mode_developer(bool flag_developer);

/** \brief Audio writing callback.
 *
 * \param data Raw audio data.
 * \param size Audio data size (in samples).
 */
extern void write_audio_callback(void *data, unsigned size);

/** \brief Image writing callback.
 *
 * \param screen_w Screen width.
 * \param screen_h Screen height.
 * \param idx Frame index to write.
 */
extern void write_frame_callback(unsigned screen_w, unsigned screen_h, unsigned idx);

/** Intro call to make.
 *
 * \param screen_w Window width.
 * \param screen_h Window height.
 * \param flag_fullscreen Enable fullscreen?
 * \param flag_record Do not play intro normally, record it to disk instead.
 */
extern int intro(unsigned screen_w, unsigned screen_h, bool flag_fullscreen, bool flag_record);

#endif

#endif
