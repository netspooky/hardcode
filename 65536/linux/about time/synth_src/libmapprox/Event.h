/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef __EVENT_H
#define __EVENT_H

#include <stdint.h>

namespace Mapprox
{

typedef struct
{
    uint8_t note;
    uint8_t velocity;
} note_event_t;

typedef struct
{
    uint8_t controller;
    uint8_t value;
} controller_event_t;

typedef struct
{
    uint8_t type;
    int step_no;
    int channel;

    union
    {
        note_event_t note;
        controller_event_t controller;
    };
} event_t;

enum { event_type_none, event_type_note_on, event_type_note_off, event_type_controller };

}

#endif // __EVENT_H
