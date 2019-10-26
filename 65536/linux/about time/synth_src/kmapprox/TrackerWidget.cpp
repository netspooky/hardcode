/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#include "TrackerWidget.h"
#include <QKeyEvent>
#include <QPainter>

namespace Mapprox
{

static const char* note_text[] =
{
	"A ", "A#", "B ", "C ", "C#", "D ", "D#", "E ", "F ", "F#", "G ", "G#"
};

TrackerWidget::TrackerWidget(QWidget *parent)
        : TrackerWidgetBase(parent)
{
	// Tracker widget setup
    editing = false;
    font = new QFont ( "Andale Mono", 10 );
    font->setFixedPitch ( 1 );

    normaltext.setRgb ( 0, 0, 255 );
    background.setRgb ( 0, 0, 0 );
    cursor_frame.setRgb ( 100, 100, 100 );
    cursor_box.setRgb ( 100, 0, 0 );
    edit_display.setRgb ( 255, 100, 100 );

    current_track = 0;
    current_column = col_note;
    leftmost_track = 0;
    last_row = -1;
    buffer = new QPixmap();
    edit_step = 0;

    done_geometry = false;
	
	// Keyjazz
    for ( int i=0; i<255; i++ )
    {
        keyjazz.note_track[i] = -1;
        keyjazz.note_voice[i] = -1;
    }
    keyjazz.current_track = -1;
}


TrackerWidget::~TrackerWidget()
{}

void TrackerWidget::resizeEvent(QResizeEvent* event)
{
	done_geometry = false;
    emit resized();
}

void TrackerWidget::paintEvent(QPaintEvent* event)
{
    emit paintevent();
}

void TrackerWidget::draw_tracker_widgets()
{
	if ( !done_geometry )
    {
        calculate_tracker_geometry();
    }

    {
        QPainter p ( buffer );
        p.setFont ( *font );

        p.fillRect ( 0, 0, width(), height(), background );
        if ( editing )
        {
            p.setPen ( edit_display );
            p.drawRect ( 0, 0, width()-1, height()-1 );
            p.drawRect ( 1, 1, width()-2, height()-2 );
        }

        // Cursor frame
        p.fillRect ( 0, cursor_frame_top, width(), cursor_frame_height, cursor_frame );
        p.fillRect ( 0, cursor_frame_bottom, width(), cursor_frame_height, cursor_frame );

        draw_track_columns ( p );

        p.end();
        last_row = song->GetRowNum();
    }

    QPainter q ( this );
    q.drawPixmap ( 0, 0, *buffer );
}

void TrackerWidget::draw_track_columns ( QPainter & p )
{
    p.save();

    p.setPen ( normaltext );
    Song::pattern_t* pat = song->GetCurrentPattern();

    // Pattern drawing loop
    int track = leftmost_track;
    int x=left_margin;

    p.translate ( left_margin, font_height );

    // Record rightmost track for cursor movement
    rightmost_track = track;

    for ( int track=leftmost_track; track < song->GetTrackCount(); track++ )
    {
        if ( x+track_width >= width() )
        {
            p.restore();
            return;
        }
        p.save();
        p.translate ( track_left_margin, 0 );
        // Record rightmost track.
        rightmost_track = track;

        // Central row
        note_event_t ne = pat->track_data[track].events[song->GetRowNum() ];
        p.drawText ( 0, cursor_frame_top + cursor_frame_height, note_event_to_text ( &ne ) );

        // Cursor
        if ( track == current_track )
        {
            p.save();
            p.translate ( 0, -font_height + cursor_frame_height/2 );
            p.setPen ( QPen ( cursor_box, 2 ) );
            p.drawRect ( col_left[current_column],
                         cursor_frame_top,
                         col_width[current_column],
                         cursor_frame_height + font_height );
            p.restore();
        }

        // Bottom half
        p.save();
        p.translate ( 0, cursor_frame_bottom + cursor_frame_height );
        for ( int row=song->GetRowNum() +1; row < pat->length; row++ )
        {
            note_event_t ne = pat->track_data[track].events[row];
            p.drawText ( 0, 0, note_event_to_text ( &ne ) );
            p.translate ( 0, font_height );
        }
        p.restore();

        // Top half
        p.save();
        p.translate ( 0, cursor_frame_top - font_height );
        for ( int row=song->GetRowNum()-1; row >= 0; row-- )
        {
            note_event_t ne = pat->track_data[track].events[row];
            p.drawText ( 0, 0, note_event_to_text ( &ne ) );
            p.translate ( 0, -font_height );
        }
        p.restore();


        p.restore();

        p.translate ( track_width, 0 );
    }

    p.restore();
}

void TrackerWidget::calculate_font_metrics()
{
    QPainter font_grabber ( this );
    font_grabber.setFont ( *font );
    font_width = font_grabber.fontMetrics().width ( "X" );
    font_height = font_grabber.fontMetrics().height();

    track_width = track_left_margin + font_width * strlen ( "C-X X XX XXX" ) + track_sep + track_right_margin;

    col_left[col_note] = 0;
    col_width[col_note] = left_margin + font_width * strlen ( " C-X" );

    col_left[col_voice] = left_margin + font_width * strlen ( " C-X " );
    col_width[col_voice] = font_width * strlen ( "X" );

    col_left[col_vol1] = left_margin + font_width * strlen ( " C-X X " );
    col_width[col_vol1] = font_width * strlen ( "X" );

    col_left[col_vol2] = left_margin + font_width * strlen ( " C-X X X" );
    col_width[col_vol2] = font_width * strlen ( "X" );

    col_left[col_effect] = left_margin + font_width * strlen ( " C-X X XX " );
    col_width[col_effect] = font_width * strlen ( "X" );

    col_left[col_data1] = left_margin + font_width * strlen ( " C-X X XX X" );
    col_width[col_data1] = font_width * strlen ( "X" );

    col_left[col_data2] = left_margin + font_width * strlen ( " C-X X XX XX" );
    col_width[col_data2] = font_width * strlen ( "X" );
}

void TrackerWidget::calculate_tracker_geometry()
{
    calculate_font_metrics();

    cursor_frame_top = ( ( height() - font_height ) / 2 ) - cursor_frame_height;
    cursor_frame_bottom = cursor_frame_top + font_height + cursor_frame_height;

    delete buffer;
    buffer = new QPixmap ( width(), height() );

    done_geometry = true;
}


void TrackerWidget::move_cursor_left()
{
    if ( current_column > col_note )
    {
        current_column = current_column - 1;
    }
    else if ( current_track == 0 )
    {
        return;
    }
    else
    {
        current_track--;
        current_column = col_data2;

        if ( current_track < leftmost_track )
        {
            leftmost_track = current_track;
        }
    }

    last_row = -1;
    update();
}

void TrackerWidget::move_cursor_right()
{
    if ( current_column < col_data2 )
    {
        current_column++;
    }
    else if ( current_track == song->GetTrackCount() -1 )
    {
        return;
    }
    else
    {
        current_track++;

        current_column = col_note;

        if ( current_track > rightmost_track )
        {
            rightmost_track++;
        }
    }

    last_row = -1;
    update();
}

void TrackerWidget::move_cursor_up()
{
    // No need to bounds-check - the song will take care of it
    song->SetRowNum ( song->GetRowNum() - 1 );

    update();
}

void TrackerWidget::move_cursor_down()
{
    song->SetRowNum ( song->GetRowNum() + 1 );

    update();
}

void TrackerWidget::keyPressEvent ( QKeyEvent* e )
{
    switch ( e->key() )
    {
            // Navigation
        case Qt::Key_Escape:
            editing = !editing;
            last_row = -1;
            update();
            break;
        case Qt::Key_Control:		// TODO: might need to change this to return or something, I can't find a way to specify the RIGHT ctrl key only with QT
            editing = false;
            song->PlayFrom ( song->GetRowNum() );
            break;
        case Qt::Key_Space:
            if ( song->Playing() )
            {
                song->Stop();
            }
            else
            {
                editing = !editing;
                last_row = -1;
                update();
            }
            break;
        case Qt::Key_Left:
            move_cursor_left();
            break;
        case Qt::Key_Right:
            move_cursor_right();
            break;
        case Qt::Key_Up:
            move_cursor_up();
            break;
        case Qt::Key_Down:
            move_cursor_down();
            break;
    }

    if ( e->isAutoRepeat() )
    {
        return;
    }

    int note=-1;
    int vol=0;

    if ( current_column == col_note )
    {
        switch ( e->key() )
        {
            case Qt::Key_Q: note = 33; break;
            case Qt::Key_2: note = 34; break;
            case Qt::Key_W: note = 35; break;
            case Qt::Key_3: note = 36; break;
            case Qt::Key_E: note = 37; break;
            case Qt::Key_R: note = 38; break;
            case Qt::Key_5: note = 39; break;
            case Qt::Key_T: note = 40; break;
            case Qt::Key_6: note = 41; break;
            case Qt::Key_Y: note = 42; break;
            case Qt::Key_7: note = 43; break;
            case Qt::Key_U: note = 44; break;
            case Qt::Key_I: note = 45; break;
            case Qt::Key_9: note = 46; break;
            case Qt::Key_O: note = 47; break;
            case Qt::Key_0: note = 48; break;
            case Qt::Key_P: note = 49; break;
            case Qt::Key_K: note = 50; break;
			case Qt::Key_Delete: note = 0; break;
        }
    }
    else if ( current_column == col_vol1 )
    {
        int remainder = current_event()->vol & 0xF;
        bool vol_updated = false;

        switch ( e->key() )
        {
            case Qt::Key_1: vol = ( 1 << 4 ) + remainder; vol_updated = true; break;
            case Qt::Key_2: vol = ( 2 << 4 ) + remainder; vol_updated = true;  break;
            case Qt::Key_3: vol = ( 3 << 4 ) + remainder; vol_updated = true;  break;
            case Qt::Key_4: vol = ( 4 << 4 ) + remainder; vol_updated = true;  break;
            case Qt::Key_5: vol = ( 5 << 4 ) + remainder; vol_updated = true;  break;
            case Qt::Key_6: vol = ( 6 << 4 ) + remainder; vol_updated = true;  break;
            case Qt::Key_7: vol = ( 7 << 4 ) + remainder; vol_updated = true;  break;
            case Qt::Key_8: vol = ( 8 << 4 ) + remainder; vol_updated = true;  break;
            case Qt::Key_9: vol = ( 9 << 4 ) + remainder; vol_updated = true;  break;
            case Qt::Key_0: vol = ( 0 << 4 ) + remainder; vol_updated = true;  break;
            case Qt::Key_A: vol = ( 10 << 4 ) + remainder; vol_updated = true;  break;
            case Qt::Key_B: vol = ( 11 << 4 ) + remainder; vol_updated = true;  break;
            case Qt::Key_C: vol = ( 12 << 4 ) + remainder; vol_updated = true;  break;
            case Qt::Key_D: vol = ( 13 << 4 ) + remainder; vol_updated = true;  break;
            case Qt::Key_E: vol = ( 14 << 4 ) + remainder; vol_updated = true;  break;
            case Qt::Key_F: vol = ( 15 << 4 ) + remainder; vol_updated = true;  break;
        }
        if ( editing && vol_updated )
        {
            current_event()->vol = vol;
            advance();
        }
    }
    else if ( current_column == col_vol2 )
    {
        int left = current_event()->vol & 0xF0;
        bool vol_updated = false;

        switch ( e->key() )
        {
            case Qt::Key_1: vol = 1 + left;  vol_updated = true; break;
            case Qt::Key_2: vol = 2 + left ;  vol_updated = true; break;
            case Qt::Key_3: vol = 3 + left;  vol_updated = true; break;
            case Qt::Key_4: vol = 4 + left;  vol_updated = true; break;
            case Qt::Key_5: vol = 5 + left;  vol_updated = true; break;
            case Qt::Key_6: vol = 6 + left;  vol_updated = true; break;
            case Qt::Key_7: vol = 7 + left;  vol_updated = true; break;
            case Qt::Key_8: vol = 8 + left;  vol_updated = true; break;
            case Qt::Key_9: vol = 9 + left;  vol_updated = true; break;
            case Qt::Key_0: vol = 0 + left;  vol_updated = true; break;
            case Qt::Key_A: vol = 10 + left;  vol_updated = true; break;
            case Qt::Key_B: vol = 11 + left;  vol_updated = true; break;
            case Qt::Key_C: vol = 12 + left;  vol_updated = true; break;
            case Qt::Key_D: vol = 13 + left;  vol_updated = true; break;
            case Qt::Key_E:  vol = 14 + left;  vol_updated = true; break;
            case Qt::Key_F: vol = 15 + left;  vol_updated = true; break;
        }
        if ( editing && vol_updated )
        {
            current_event()->vol = vol;
            advance();
        }
    }
    else if ( current_column == col_effect )
    {
        int effect;
        bool effect_updated = false;

        switch ( e->key() )
        {
            case Qt::Key_1: effect = 1;  effect_updated = true; break;
            case Qt::Key_2: effect = 2;  effect_updated = true; break;
            case Qt::Key_3: effect = 3;  effect_updated = true; break;
            case Qt::Key_4: effect = 4;  effect_updated = true; break;
            case Qt::Key_5: effect = 5;  effect_updated = true; break;
            case Qt::Key_6: effect = 6;  effect_updated = true; break;
            case Qt::Key_7: effect = 7;  effect_updated = true; break;
            case Qt::Key_8: effect = 8;  effect_updated = true; break;
            case Qt::Key_9: effect = 9;  effect_updated = true; break;
            case Qt::Key_0: effect = 0;  effect_updated = true; break;
            case Qt::Key_A: effect = 10;  effect_updated = true; break;
            case Qt::Key_B: effect = 11;  effect_updated = true; break;
            case Qt::Key_C: effect = 12;  effect_updated = true; break;
            case Qt::Key_D: effect = 13;  effect_updated = true; break;
            case Qt::Key_E:  effect = 14;  effect_updated = true; break;
            case Qt::Key_F: effect = 15;  effect_updated = true; break;
        }
        if ( editing && effect_updated )
        {
            current_event()->effect_num = effect;
            advance();
        }
    }
    else if ( current_column == col_data1 )
    {
        int remainder = current_event()->effect_param & 0xF;
        bool effect_param_updated = false;
        int effect_param;

        switch ( e->key() )
        {
            case Qt::Key_1: effect_param = ( 1 << 4 ) + remainder; effect_param_updated = true; break;
            case Qt::Key_2: effect_param = ( 2 << 4 ) + remainder; effect_param_updated = true;  break;
            case Qt::Key_3: effect_param = ( 3 << 4 ) + remainder; effect_param_updated = true;  break;
            case Qt::Key_4: effect_param = ( 4 << 4 ) + remainder; effect_param_updated = true;  break;
            case Qt::Key_5: effect_param = ( 5 << 4 ) + remainder; effect_param_updated = true;  break;
            case Qt::Key_6: effect_param = ( 6 << 4 ) + remainder; effect_param_updated = true;  break;
            case Qt::Key_7: effect_param = ( 7 << 4 ) + remainder; effect_param_updated = true;  break;
            case Qt::Key_8: effect_param = ( 8 << 4 ) + remainder; effect_param_updated = true;  break;
            case Qt::Key_9: effect_param = ( 9 << 4 ) + remainder; effect_param_updated = true;  break;
            case Qt::Key_0: effect_param = ( 0 << 4 ) + remainder; effect_param_updated = true;  break;
            case Qt::Key_A: effect_param = ( 10 << 4 ) + remainder; effect_param_updated = true;  break;
            case Qt::Key_B: effect_param = ( 11 << 4 ) + remainder; effect_param_updated = true;  break;
            case Qt::Key_C: effect_param = ( 12 << 4 ) + remainder; effect_param_updated = true;  break;
            case Qt::Key_D: effect_param = ( 13 << 4 ) + remainder; effect_param_updated = true;  break;
            case Qt::Key_E: effect_param = ( 14 << 4 ) + remainder; effect_param_updated = true;  break;
            case Qt::Key_F: effect_param = ( 15 << 4 ) + remainder; effect_param_updated = true;  break;
        }
        if ( editing && effect_param_updated )
        {
            current_event()->effect_param = effect_param;
            advance();
        }
    }
    else if ( current_column == col_data2 )
    {
        int left = current_event()->effect_param& 0xF0;
        bool effect_param_updated = false;
        int effect_param;

        switch ( e->key() )
        {
            case Qt::Key_1: effect_param = 1 + left;  effect_param_updated = true; break;
            case Qt::Key_2: effect_param = 2 + left ;  effect_param_updated = true; break;
            case Qt::Key_3: effect_param = 3 + left;  effect_param_updated = true; break;
            case Qt::Key_4: effect_param = 4 + left;  effect_param_updated = true; break;
            case Qt::Key_5: effect_param = 5 + left;  effect_param_updated = true; break;
            case Qt::Key_6: effect_param = 6 + left;  effect_param_updated = true; break;
            case Qt::Key_7: effect_param = 7 + left;  effect_param_updated = true; break;
            case Qt::Key_8: effect_param = 8 + left;  effect_param_updated = true; break;
            case Qt::Key_9: effect_param = 9 + left;  effect_param_updated = true; break;
            case Qt::Key_0: effect_param = 0 + left;  effect_param_updated = true; break;
            case Qt::Key_A: effect_param = 10 + left;  effect_param_updated = true; break;
            case Qt::Key_B: effect_param = 11 + left;  effect_param_updated = true; break;
            case Qt::Key_C: effect_param = 12 + left;  effect_param_updated = true; break;
            case Qt::Key_D: effect_param = 13 + left;  effect_param_updated = true; break;
            case Qt::Key_E:  effect_param = 14 + left;  effect_param_updated = true; break;
            case Qt::Key_F: effect_param = 15 + left;  effect_param_updated = true; break;
        }
        if ( editing && effect_param_updated )
        {
            current_event()->effect_param = effect_param;
            advance();
        }
    }

    if ( note>=0 )
    {
        play_note ( note );
    }
}

void TrackerWidget::keyReleaseEvent ( QKeyEvent* e )
{
    if ( e->isAutoRepeat() )
    {
        return;
    }

    int note=0;

    if ( current_column == col_note )
    {
        switch ( e->key() )
        {
            case Qt::Key_Q: note = 33; break;
            case Qt::Key_2: note = 34; break;
            case Qt::Key_W: note = 35; break;
            case Qt::Key_3: note = 36; break;
            case Qt::Key_E: note = 37; break;
            case Qt::Key_R: note = 38; break;
            case Qt::Key_5: note = 39; break;
            case Qt::Key_T: note = 40; break;
            case Qt::Key_6: note = 41; break;
            case Qt::Key_Y: note = 42; break;
            case Qt::Key_7: note = 43; break;
            case Qt::Key_U: note = 44; break;
            case Qt::Key_I: note = 45; break;
            case Qt::Key_9: note = 46; break;
            case Qt::Key_O: note = 47; break;
            case Qt::Key_0: note = 48; break;
            case Qt::Key_P: note = 49; break;
            case Qt::Key_K: note = 50; break;
        }
    }

    if ( note )
    {
        stop_note ( note );
    }
}

const char* TrackerWidget::note_event_to_text ( const note_event_t* note_event )
{
    static char result[14];
    char flag[] = " ";
    char note[] = "---";
    char voice[] = "-";
    char vol[] = "--";
    char effect[] = "---";

    if ( note_event->note )
    {
        int octave_n = ( note_event->note - 6 ) / 12;
        int note_n = ( note_event->note - 6 ) % 12;
        sprintf ( note, "%s%d", note_text[note_n], octave_n );
        sprintf ( voice, "%X", note_event->voice );
    }

    if ( note_event->vol )
    {
        sprintf ( vol, "%02X", note_event->vol );
    }

    if ( note_event->effect_num || note_event->effect_param )
    {
        sprintf ( effect, "%X%02X", note_event->effect_num, note_event->effect_param );
    }

    sprintf ( result, "%s%s %s %s %s", flag, note, voice, vol, effect );

    return result;
}

void TrackerWidget::advance()
{
    int row_num = song->GetRowNum() + edit_step;
    if ( row_num > song->GetCurrentPattern()->length )
    {
        row_num -= song->GetCurrentPattern()->length;
    }
    song->SetRowNum ( row_num );
	//update();
}

void TrackerWidget::play_note ( int note )
{
    note_event_t ne;
    ne.note = note;
    ne.flags = NOTE_FLAG_TRIGGER;
    ne.voice = current_voice;
    ne.vol = 0;
    ne.effect_num = 0;
    ne.effect_param = 0;

    // Move track
    keyjazz.current_track++;
    if ( keyjazz.current_track >= song->GetTrackCount() )
    {
        keyjazz.current_track = 0;
    }

    if(note) song->SendNoteEvent ( keyjazz.current_track, ne );
    if ( editing )
    {
        song->GetEvent(current_track)->flags = ne.flags;
        song->GetEvent(current_track)->note = ne.note;
        song->GetEvent(current_track)->voice = current_voice;
//        song->InsertEvent ( tracker.current_track, ne );
        advance();
    }
    keyjazz.note_track[note] = keyjazz.current_track;
    keyjazz.note_voice[note] = current_voice;
}

void TrackerWidget::stop_note ( int note )
{
    if ( keyjazz.note_track[note] != -1 )
    {
        note_event_t ne;
        ne.note = note;
        ne.flags = NOTE_FLAG_GATE;
        ne.voice = keyjazz.note_voice[note];

        song->SendNoteEvent ( keyjazz.note_track[note], ne );

        keyjazz.note_track[note] = -1;
    }
}

}
