/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef MAPPROXTRACKERWIDGET_H
#define MAPPROXTRACKERWIDGET_H

#include <QWidget>
#include "TrackerWidgetBase.h"
#include "Song.h"
#include "mapprox.h"

namespace Mapprox
{

class TrackerWidget : public TrackerWidgetBase
{
    Q_OBJECT
public:
	enum { curs_notes, curs_effects };
	enum { col_note, col_voice, col_vol1, col_vol2, col_effect, col_data1, col_data2, col_max };
protected:
    virtual void resizeEvent(QResizeEvent* event);
    virtual void paintEvent(QPaintEvent* event);
	
	// Old tracker struct from MainWindow.cpp
	QFont* font;

	// Colours
	QColor normaltext;
	QColor background;
	QColor cursor_frame;
	QColor cursor_box;
	QColor edit_display;

	// Editing
	bool editing;
	int edit_step;

	// geometry
	static const int left_margin = 2;
	static const int track_left_margin = 2;
	static const int track_right_margin = 10;
	static const int cursor_frame_height = 2;
	static const int track_sep = 3;

	bool done_geometry;
	int font_width;
	int font_height;
	int cursor_frame_top;
	int cursor_frame_bottom;

	int leftmost_track;
	int rightmost_track;
	int track_width;

	int current_track;

	int current_curs;
	int current_column;

	int col_left[col_max];
	int col_width[col_max];
	
	int last_row;

	QPixmap* buffer;
	
	Song* song;
	int current_voice;
	
	
	struct
	{
		int note_track[255];
		int note_voice[255];
		int current_track;
	}
	keyjazz;

	note_event_t* current_event() { return song->GetEvent ( keyjazz.current_track ); }
	void move_cursor_left();
	void move_cursor_right();
	void move_cursor_up();
	void move_cursor_down();
	void calculate_font_metrics();
	void calculate_tracker_geometry();
	const char* note_event_to_text ( const note_event_t* note_event );
	void advance();
	void play_note ( int note );
	void stop_note ( int note );
	
signals:
    void resized();
    void paintevent();
public:
    TrackerWidget(QWidget *parent = 0);
    ~TrackerWidget();
	bool isEditMode() { return editing; }
	void draw_tracker_widgets();
	void draw_track_columns ( QPainter& p );
	void setSong(Song *s) { song = s; }
	void keyPressEvent ( QKeyEvent* e );
	void keyReleaseEvent ( QKeyEvent* e );
	void setEditStep (int step) { edit_step = step; }
	void setCurrentVoice (int v) { current_voice = v; }
};

}

#endif
