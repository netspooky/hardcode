/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef MAPPROXMAINWINDOW_H
#define MAPPROXMAINWINDOW_H

#include <QMainWindow>
#include <ui_MainWindowBase.h>
#include <mapprox.h>
#include <SynthContainer.h>
#include <Audio.h>

// Here be dragons...

namespace Mapprox
{

class MainWindow : public QMainWindow, private Ui::MainWindowBase
{
        Q_OBJECT
    private:
        Audio* output;
        SynthContainer* synth_container;
        QString song_filename;

        struct
        {
            int current_voice;
            int current_gen;

            QListWidgetItem* voice_list_items[SynthContainer::max_voices];
        }
        voice_ed;

        struct
        {
            QColor line;
            QColor background;
            QColor highlight;
            QColor loop;

            int current_node;
            bool done_geometry;

            int width;
            int height;

            Generator::EnvelopeData* current_envelope;
        }
        volume_ed;

        struct
        {
            QColor line;
            QColor background;
            QColor highlight;
            QColor loop;

            int current_node;
            bool done_geometry;

            int width;
            int height;

            Generator::EnvelopeData* current_envelope;
        }
        pitch_ed;

        struct
        {
            QColor line;
            QColor background;
            QColor highlight;
            QColor loop;

            int current_node;
            bool done_geometry;

            int width;
            int height;

            Generator::EnvelopeData* current_envelope;
        }
        filter_ed;

        Generator* current_generator();
        Voice* current_voice();
        void set_harmonic ( int harmonic, int value );
        void set_generator ( int gen );
        void redraw_generator();
        void redraw_voicelist();
    private slots:
        void RenameVoice ( const QString& name );
        void ResizeVolume();
        void PaintVolume();
        void ResizePitch();
        void PaintPitch();
        void ResizeFilter();
        void PaintFilter();
        void voice_changed ( int voice );
        void base_func_changed ( int );
        void render_clicked();
        void enable_gen ( int state );
        void gen_clicked0() { set_generator ( 0 ); }
        void gen_clicked1() { set_generator ( 1 ); }
        void gen_clicked2() { set_generator ( 2 ); }
        void gen_clicked3() { set_generator ( 3 ); }
        void harmonic_changed1 ( int val ) { set_harmonic ( 0, val ); }
        void harmonic_changed2 ( int val ) { set_harmonic ( 1, val ); }
        void harmonic_changed3 ( int val ) { set_harmonic ( 2, val ); }
        void harmonic_changed4 ( int val ) { set_harmonic ( 3, val ); }
        void harmonic_changed5 ( int val ) { set_harmonic ( 4, val ); }
        void harmonic_changed6 ( int val ) { set_harmonic ( 5, val ); }
        void harmonic_changed7 ( int val ) { set_harmonic ( 6, val ); }
        void harmonic_changed8 ( int val ) { set_harmonic ( 7, val ); }
        void volume_edit_current_node_changed ( int val );
        void volume_edit_loop_checked ( int val );
        void volume_edit_loop_start_changed ( int val );
        void volume_edit_loop_stop_changed ( int val );
        void volume_edit_duration_changed ( int val );
        void volume_edit_value_changed ( int val );
        void volume_edit_length_changed ( int val );
        void pitch_edit_current_node_changed ( int val );
        void pitch_edit_loop_checked ( int val );
        void pitch_edit_loop_start_changed ( int val );
        void pitch_edit_loop_stop_changed ( int val );
        void pitch_edit_duration_changed ( int val );
        void pitch_edit_value_changed ( int val );
        void pitch_edit_length_changed ( int val );
        void pitch_edit_scale_changed ( int val );
        void filter_edit_current_node_changed ( int val );
        void filter_edit_loop_checked ( int val );
        void filter_edit_loop_start_changed ( int val );
        void filter_edit_loop_stop_changed ( int val );
        void filter_edit_duration_changed ( int val );
        void filter_edit_value_changed ( int val );
        void filter_edit_length_changed ( int val );
        void filter_edit_resonance_changed ( int val );
        void octave_spin_changed ( int val );
        void semitone_spin_changed ( int val );
        void finetune_spin_changed ( int val );
        void delay_left_delay_slider_changed ( int val );
        void delay_right_delay_slider_changed ( int val );
        void delay_left_feedback_slider_changed ( int val );
        void delay_right_feedback_slider_changed ( int val );
        void reverb_send_slider_changed ( int val );
        void gain_left_slider_changed ( int val );
        void gain_right_slider_changed ( int val );
        void distortion_threshold_slider_changed ( int val );
    public:
        MainWindow ( QWidget *parent = 0 );

        ~MainWindow();
        void keyPressEvent ( QKeyEvent* e );
        void keyReleaseEvent ( QKeyEvent* e );
    public slots:
        void OpenSong();
        void SaveSong();
        void SaveAs();
        void SaveVoice();
        void LoadVoice();
        void GoToInstrumentEditor();
        void GoToEffects();
        void MakeChorus();
        void PlaySong();
        void Stop();
        void RecordSong();
};

}

#endif
