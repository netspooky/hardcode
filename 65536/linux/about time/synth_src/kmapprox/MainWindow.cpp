/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#include "MainWindow.h"

#include <iostream>
#include <QKeyEvent>
#include <QPainter>
#include <QTimer>
#include <QFileDialog>
#include <math.h>

using namespace std;

using namespace Mapprox;


MainWindow::MainWindow ( QWidget *parent )
        : QMainWindow ( parent ), Ui::MainWindowBase(), song_filename ( "" )
{
    synth_container = new SynthContainer();

    setupUi ( this );

    connect ( actionOpen_Song, SIGNAL ( triggered() ), this, SLOT ( OpenSong() ) );
    connect ( actionSave, SIGNAL ( triggered() ), this, SLOT ( SaveSong() ) );
    connect ( actionSave_As, SIGNAL ( triggered() ), this, SLOT ( SaveAs() ) );
    connect ( actionQuit, SIGNAL ( triggered() ), qApp, SLOT ( quit() ) );
    connect ( actionGo_to_Instrument_Editor, SIGNAL ( triggered() ), this, SLOT ( GoToInstrumentEditor() ) );
    connect ( actionGo_to_Effects, SIGNAL ( triggered() ), this, SLOT ( GoToEffects() ) );
    connect ( actionSave_Voice, SIGNAL ( triggered() ), this, SLOT ( SaveVoice() ) );
    connect ( actionLoad_Voice, SIGNAL ( triggered() ), this, SLOT ( LoadVoice() ) );
    connect ( actionMakeChorus, SIGNAL ( triggered() ), this, SLOT ( MakeChorus() ) );
    connect ( actionRecord, SIGNAL ( triggered() ), this, SLOT ( RecordSong() ) );
    connect ( actionPlay, SIGNAL ( triggered() ), this, SLOT ( PlaySong() ) );
    connect ( actionStop, SIGNAL ( triggered() ), this, SLOT ( Stop() ) );


    // Voice control setup
    connect ( voice_name_lineedit, SIGNAL ( textChanged ( const QString& ) ), this, SLOT ( RenameVoice ( const QString& ) ) );

    // Volume widget setup
    volume_ed.current_node = 0;
    volume_ed.done_geometry = 0;
    connect ( volume_graph, SIGNAL ( resized() ), this, SLOT ( ResizeVolume() ) );
    connect ( volume_graph, SIGNAL ( paintevent() ), this, SLOT ( PaintVolume() ) );
    connect ( volume_env_loop_check, SIGNAL ( stateChanged ( int ) ), this, SLOT ( volume_edit_loop_checked ( int ) ) );
    connect ( volume_env_loop_start_spin, SIGNAL ( valueChanged ( int ) ), this, SLOT ( volume_edit_loop_start_changed ( int ) ) );
    connect ( volume_env_loop_stop_spin, SIGNAL ( valueChanged ( int ) ), this, SLOT ( volume_edit_loop_stop_changed ( int ) ) );
    connect ( volume_env_edit_spin, SIGNAL ( valueChanged ( int ) ), this, SLOT ( volume_edit_current_node_changed ( int ) ) );
    connect ( volume_env_duration_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( volume_edit_duration_changed ( int ) ) );
    connect ( volume_env_value_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( volume_edit_value_changed ( int ) ) );
    connect ( volume_env_length_spin, SIGNAL ( valueChanged ( int ) ), this, SLOT ( volume_edit_length_changed ( int ) ) );

    // Pitch widget setup
    pitch_ed.current_node = 0;
    pitch_ed.done_geometry = 0;
    connect ( pitch_graph, SIGNAL ( resized() ), this, SLOT ( ResizePitch() ) );
    connect ( pitch_graph, SIGNAL ( paintevent() ), this, SLOT ( PaintPitch() ) );
    connect ( pitch_env_loop_check, SIGNAL ( stateChanged ( int ) ), this, SLOT ( pitch_edit_loop_checked ( int ) ) );
    connect ( pitch_env_loop_start_spin, SIGNAL ( valueChanged ( int ) ), this, SLOT ( pitch_edit_loop_start_changed ( int ) ) );
    connect ( pitch_env_loop_stop_spin, SIGNAL ( valueChanged ( int ) ), this, SLOT ( pitch_edit_loop_stop_changed ( int ) ) );
    connect ( pitch_env_edit_spin, SIGNAL ( valueChanged ( int ) ), this, SLOT ( pitch_edit_current_node_changed ( int ) ) );
    connect ( pitch_env_duration_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( pitch_edit_duration_changed ( int ) ) );
    connect ( pitch_env_value_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( pitch_edit_value_changed ( int ) ) );
    connect ( pitch_env_length_spin, SIGNAL ( valueChanged ( int ) ), this, SLOT ( pitch_edit_length_changed ( int ) ) );
    connect ( pitch_env_scale_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( pitch_edit_scale_changed ( int ) ) );
    connect ( octave_spin, SIGNAL ( valueChanged ( int ) ), this, SLOT ( octave_spin_changed ( int ) ) );
    connect ( semitone_spin, SIGNAL ( valueChanged ( int ) ), this, SLOT ( semitone_spin_changed ( int ) ) );
    connect ( finetune_spin, SIGNAL ( valueChanged ( int ) ), this, SLOT ( finetune_spin_changed ( int ) ) );

    // Filter widget setup
    filter_ed.current_node = 0;
    filter_ed.done_geometry = 0;
    connect ( filter_graph, SIGNAL ( resized() ), this, SLOT ( ResizeFilter() ) );
    connect ( filter_graph, SIGNAL ( paintevent() ), this, SLOT ( PaintFilter() ) );
    connect ( filter_env_loop_check, SIGNAL ( stateChanged ( int ) ), this, SLOT ( filter_edit_loop_checked ( int ) ) );
    connect ( filter_env_loop_start_spin, SIGNAL ( valueChanged ( int ) ), this, SLOT ( filter_edit_loop_start_changed ( int ) ) );
    connect ( filter_env_loop_stop_spin, SIGNAL ( valueChanged ( int ) ), this, SLOT ( filter_edit_loop_stop_changed ( int ) ) );
    connect ( filter_env_edit_spin, SIGNAL ( valueChanged ( int ) ), this, SLOT ( filter_edit_current_node_changed ( int ) ) );
    connect ( filter_env_duration_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( filter_edit_duration_changed ( int ) ) );
    connect ( filter_env_value_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( filter_edit_value_changed ( int ) ) );
    connect ( filter_env_length_spin, SIGNAL ( valueChanged ( int ) ), this, SLOT ( filter_edit_length_changed ( int ) ) );
    connect ( filter_env_resonance_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( filter_edit_resonance_changed ( int ) ) );

    // Effects
    connect ( delay_left_delay_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( delay_left_delay_slider_changed ( int ) ) );
    connect ( delay_right_delay_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( delay_right_delay_slider_changed ( int ) ) );
    connect ( delay_left_feedback_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( delay_left_feedback_slider_changed ( int ) ) );
    connect ( delay_right_feedback_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( delay_right_feedback_slider_changed ( int ) ) );
    connect ( gain_left_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( gain_left_slider_changed ( int ) ) );
    connect ( gain_right_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( gain_right_slider_changed ( int ) ) );
    connect ( reverb_send_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( reverb_send_slider_changed ( int ) ) );
    connect ( distortion_threshold_slider, SIGNAL ( valueChanged ( int ) ), this, SLOT ( distortion_threshold_slider_changed ( int ) ) );


    // Voice list setup

    for ( int i = 0; i < SynthContainer::max_voices; i++ )
    {
        voice_ed.voice_list_items[i] = new QListWidgetItem ( voice_list );
    }

    redraw_voicelist();

    connect ( voice_list, SIGNAL ( currentRowChanged ( int ) ), this, SLOT ( voice_changed ( int ) ) );

    voice_ed.current_voice = 0;
    voice_ed.current_gen = 0;

    // Graph colours
    volume_ed.line.setRgb ( 200, 200, 200 );
    volume_ed.background.setRgb ( 0, 0, 0 );
    volume_ed.highlight.setRgb ( 255, 100, 100 );
    volume_ed.loop.setRgb ( 100, 255, 100 );
    pitch_ed.line.setRgb ( 200, 200, 200 );
    pitch_ed.background.setRgb ( 0, 0, 0 );
    pitch_ed.highlight.setRgb ( 255, 100, 100 );
    pitch_ed.loop.setRgb ( 100, 255, 100 );
    filter_ed.line.setRgb ( 200, 200, 200 );
    filter_ed.background.setRgb ( 0, 0, 0 );
    filter_ed.highlight.setRgb ( 255, 100, 100 );
    filter_ed.loop.setRgb ( 100, 255, 100 );

    base_func_combo->addItem ( "Sine" );
    base_func_combo->addItem ( "Saw" );
    base_func_combo->addItem ( "Square" );
    base_func_combo->addItem ( "Pow" );
    base_func_combo->addItem ( "Gauss" );

    connect ( base_func_combo, SIGNAL ( currentIndexChanged ( int ) ), this, SLOT ( base_func_changed ( int ) ) );
    connect ( render_button, SIGNAL ( clicked() ), this, SLOT ( render_clicked() ) );
    connect ( gen_enable, SIGNAL ( stateChanged ( int ) ), this, SLOT ( enable_gen ( int ) ) );

    connect ( gen_radio0, SIGNAL ( clicked() ), this, SLOT ( gen_clicked0() ) );
    connect ( gen_radio1, SIGNAL ( clicked() ), this, SLOT ( gen_clicked1() ) );
    connect ( gen_radio2, SIGNAL ( clicked() ), this, SLOT ( gen_clicked2() ) );
    connect ( gen_radio3, SIGNAL ( clicked() ), this, SLOT ( gen_clicked3() ) );

    // Harmonic controls
    connect ( harmonic1, SIGNAL ( valueChanged ( int ) ), this, SLOT ( harmonic_changed1 ( int ) ) );
    connect ( harmonic2, SIGNAL ( valueChanged ( int ) ), this, SLOT ( harmonic_changed2 ( int ) ) );
    connect ( harmonic3, SIGNAL ( valueChanged ( int ) ), this, SLOT ( harmonic_changed3 ( int ) ) );
    connect ( harmonic4, SIGNAL ( valueChanged ( int ) ), this, SLOT ( harmonic_changed4 ( int ) ) );
    connect ( harmonic5, SIGNAL ( valueChanged ( int ) ), this, SLOT ( harmonic_changed5 ( int ) ) );
    connect ( harmonic6, SIGNAL ( valueChanged ( int ) ), this, SLOT ( harmonic_changed6 ( int ) ) );
    connect ( harmonic7, SIGNAL ( valueChanged ( int ) ), this, SLOT ( harmonic_changed7 ( int ) ) );
    connect ( harmonic8, SIGNAL ( valueChanged ( int ) ), this, SLOT ( harmonic_changed8 ( int ) ) );

    // Set up all the widgets
    redraw_generator();

    // Editing
    voice_ed.current_voice = 0;

    // Make sure we get all keyboard events
//    grabKeyboard();

    output = new Audio();

    output->SetSource ( synth_container );
    output->Start();
}


MainWindow::~MainWindow()
{
    output->Stop();
    delete synth_container;
    delete output;
}


void MainWindow::RenameVoice ( const QString& name )
{
    current_voice()->SetName ( ( const char* ) name.toAscii() );
    redraw_voicelist();
}

void MainWindow::redraw_voicelist()
{
    for ( int i = 0; i < SynthContainer::max_voices; i++ )
    {
        voice_ed.voice_list_items[i]->setText ( synth_container->GetVoice ( i )->GetName() );
    }
}

void MainWindow::LoadVoice()
{
//    releaseKeyboard();
    QString s = QFileDialog::getOpenFileName ( 0, "Choose a voice file", "", "Voices (*.mvoc)" );

    if ( !s.isNull() )
    {
        BitBuffer buffer ( ( const char* ) s.toAscii() );
        current_voice()->LoadData ( buffer );
    }

//    grabKeyboard();

    redraw_generator();
}

void MainWindow::SaveVoice()
{
//    releaseKeyboard();
    QString s = QFileDialog::getSaveFileName ( 0, "Choose file to save voice to", "", "Voices (*.mvoc)" );

    if ( !s.isNull() )
    {
        BitBuffer buffer;
        current_voice()->PushData ( buffer );
        buffer.Save ( s.toAscii() );
    }

//    grabKeyboard();
}

void MainWindow::MakeChorus()
{
    BitBuffer buffer;

    current_generator()->PushData ( buffer );

    for ( int g = 0; g < Voice::max_generators; g++ )
    {
        buffer.Reset();
        current_voice()->GetGenerator ( g )->LoadData ( buffer );
//        current_voice()->GetGenerator(g)->SetEnabled(1);
    }

    update();
}

void MainWindow::GoToInstrumentEditor()
{
    mainStack->setCurrentWidget ( instrumentPage );
}

void MainWindow::GoToEffects()
{
    mainStack->setCurrentWidget ( effectPage );
}


void MainWindow::ResizeVolume()
{
    volume_ed.done_geometry = false;
}

void MainWindow::PaintVolume()
{
    if ( !volume_ed.done_geometry )
    {
        volume_ed.width = volume_graph->width() - 4;
        volume_ed.height = volume_graph->height() - 4;
    }

    volume_ed.current_envelope = current_generator()->GetVolumeEnv();

    volume_env_length_spin->setValue ( volume_ed.current_envelope->length );
    volume_env_loop_start_spin->setValue ( volume_ed.current_envelope->loop_start );
    volume_env_loop_stop_spin->setValue ( volume_ed.current_envelope->loop_end );
    volume_env_edit_spin->setValue ( volume_ed.current_node );
    volume_env_duration_slider->setValue ( volume_ed.current_envelope->duration[volume_ed.current_node] );
    volume_env_value_slider->setValue ( ( int ) ( volume_ed.current_envelope->value[volume_ed.current_node]*255.0f ) );

    if ( volume_ed.current_envelope->loop )
    {
        volume_env_loop_check->setCheckState ( Qt::Checked );
    }
    else
    {
        volume_env_loop_check->setCheckState ( Qt::Unchecked );
    }

    // Do the painting
    QPainter p ( volume_graph );

    // Blank background
    p.fillRect ( 0, 0, volume_graph->width(), volume_graph->height(), volume_ed.background );

    // Calculate scale
    float env_width = 0;

    for ( int i = 0; i < volume_ed.current_envelope->length; i++ )
    {
        env_width += volume_ed.current_envelope->duration[i];
    }

    float scale = ( ( float ) volume_ed.width ) / env_width;

    float xpos = 0, ypos = volume_ed.height;

    // Translate and draw it
    p.translate ( 2, 2 );

    for ( int i = 0; i < volume_ed.current_envelope->length; i++ )
    {
        float nextx = xpos + ( ( float ) volume_ed.current_envelope->duration[i] * scale );
        float nexty = ( 1.0f - volume_ed.current_envelope->value[i] ) * ( float ) volume_ed.height;

        p.setPen ( volume_ed.line );
        p.drawLine ( ( int ) xpos, ( int ) ypos, ( int ) nextx, ( int ) nexty );

        if ( i == volume_ed.current_node )
        {
            p.setPen ( volume_ed.highlight );
            p.drawRect ( ( int ) nextx - 4, ( int ) nexty - 4, ( int ) 9, ( int ) 9 );
        }

        if ( volume_ed.current_envelope->loop )
        {
            if ( i == volume_ed.current_envelope->loop_start || i == volume_ed.current_envelope->loop_end )
            {
                p.setPen ( volume_ed.loop );
                p.drawLine ( ( int ) nextx, ( int ) 0, ( int ) nextx, ( int ) volume_ed.height );
            }
        }

        xpos = nextx; ypos = nexty;
    }
}

void MainWindow::ResizePitch()
{
    pitch_ed.done_geometry = false;
}

void MainWindow::PaintPitch()
{
    if ( !pitch_ed.done_geometry )
    {
        pitch_ed.width = pitch_graph->width() - 4;
        pitch_ed.height = pitch_graph->height() - 4;
    }

    pitch_ed.current_envelope = current_generator()->GetPitchEnv();

    pitch_env_scale_slider->setValue ( ( int ) pow ( ( current_generator()->GetPitchScale() * 4096.0f ), 1.0f / 3.0f ) );
    pitch_env_length_spin->setValue ( pitch_ed.current_envelope->length );
    pitch_env_loop_start_spin->setValue ( pitch_ed.current_envelope->loop_start );
    pitch_env_loop_stop_spin->setValue ( pitch_ed.current_envelope->loop_end );
    pitch_env_edit_spin->setValue ( pitch_ed.current_node );
    pitch_env_duration_slider->setValue ( pitch_ed.current_envelope->duration[pitch_ed.current_node] );
    pitch_env_value_slider->setValue ( ( int ) ( pitch_ed.current_envelope->value[pitch_ed.current_node]*255.0f ) );

    if ( pitch_ed.current_envelope->loop )
    {
        pitch_env_loop_check->setCheckState ( Qt::Checked );
    }
    else
    {
        pitch_env_loop_check->setCheckState ( Qt::Unchecked );
    }

    // Do the painting
    QPainter p ( pitch_graph );

    // Blank background
    p.fillRect ( 0, 0, pitch_graph->width(), pitch_graph->height(), pitch_ed.background );

    // Calculate scale
    float env_width = 0;

    for ( int i = 0; i < pitch_ed.current_envelope->length; i++ )
    {
        env_width += pitch_ed.current_envelope->duration[i];
    }

    float scale = ( ( float ) pitch_ed.width ) / env_width;

    float xpos = 0, ypos = pitch_ed.height / 2;

    // Translate, then draw it
    p.translate ( 2, 2 );

    p.setPen ( pitch_ed.loop );
    p.drawLine ( 0, pitch_ed.height / 2, pitch_ed.width, pitch_ed.height / 2 );

    for ( int i = 0; i < pitch_ed.current_envelope->length; i++ )
    {
        float nextx = xpos + ( ( float ) pitch_ed.current_envelope->duration[i] * scale );
        float nexty = ( 1.0f - pitch_ed.current_envelope->value[i] ) * ( float ) ( pitch_ed.height / 2 );

        p.setPen ( pitch_ed.line );
        p.drawLine ( ( int ) xpos, ( int ) ypos, ( int ) nextx, ( int ) nexty );

        if ( i == pitch_ed.current_node )
        {
            p.setPen ( pitch_ed.highlight );
            p.drawRect ( ( int ) nextx - 4, ( int ) nexty - 4, ( int ) 9, ( int ) 9 );
        }

        if ( pitch_ed.current_envelope->loop )
        {
            if ( i == pitch_ed.current_envelope->loop_start || i == pitch_ed.current_envelope->loop_end )
            {
                p.setPen ( pitch_ed.loop );
                p.drawLine ( ( int ) nextx, ( int ) 0, ( int ) nextx, ( int ) pitch_ed.height );
            }
        }

        xpos = nextx; ypos = nexty;
    }
}


void MainWindow::ResizeFilter()
{
    filter_ed.done_geometry = false;
}

void MainWindow::PaintFilter()
{
    if ( !filter_ed.done_geometry )
    {
        filter_ed.width = filter_graph->width() - 4;
        filter_ed.height = filter_graph->height() - 4;
    }

    filter_ed.current_envelope = current_generator()->GetFilterEnv();

    filter_env_length_spin->setValue ( filter_ed.current_envelope->length );
    filter_env_loop_start_spin->setValue ( filter_ed.current_envelope->loop_start );
    filter_env_loop_stop_spin->setValue ( filter_ed.current_envelope->loop_end );
    filter_env_edit_spin->setValue ( filter_ed.current_node );
    filter_env_duration_slider->setValue ( filter_ed.current_envelope->duration[filter_ed.current_node] );
    filter_env_value_slider->setValue ( ( int ) ( filter_ed.current_envelope->value[filter_ed.current_node]*255.0f ) );

    if ( filter_ed.current_envelope->loop )
    {
        filter_env_loop_check->setCheckState ( Qt::Checked );
    }
    else
    {
        filter_env_loop_check->setCheckState ( Qt::Unchecked );
    }

    // Do the painting
    QPainter p ( filter_graph );

    // Blank background
    p.fillRect ( 0, 0, filter_graph->width(), filter_graph->height(), filter_ed.background );

    // Calculate scale
    float env_width = 0;

    for ( int i = 0; i < filter_ed.current_envelope->length; i++ )
    {
        env_width += filter_ed.current_envelope->duration[i];
    }

    float scale = ( ( float ) filter_ed.width ) / env_width;

    float xpos = 0, ypos = filter_ed.height;

    // Translate and draw it
    p.translate ( 2, 2 );

    for ( int i = 0; i < filter_ed.current_envelope->length; i++ )
    {
        float nextx = xpos + ( ( float ) filter_ed.current_envelope->duration[i] * scale );
        float nexty = ( 1.0f - filter_ed.current_envelope->value[i] ) * ( float ) filter_ed.height;

        p.setPen ( filter_ed.line );
        p.drawLine ( ( int ) xpos, ( int ) ypos, ( int ) nextx, ( int ) nexty );

        if ( i == filter_ed.current_node )
        {
            p.setPen ( filter_ed.highlight );
            p.drawRect ( ( int ) nextx - 4, ( int ) nexty - 4, ( int ) 9, ( int ) 9 );
        }

        if ( filter_ed.current_envelope->loop )
        {
            if ( i == filter_ed.current_envelope->loop_start || i == filter_ed.current_envelope->loop_end )
            {
                p.setPen ( filter_ed.loop );
                p.drawLine ( ( int ) nextx, ( int ) 0, ( int ) nextx, ( int ) filter_ed.height );
            }
        }

        xpos = nextx; ypos = nexty;
    }
}

void MainWindow::volume_edit_current_node_changed ( int val )
{
    if ( val >= 0 && val < volume_ed.current_envelope->length )
    {
        volume_ed.current_node = val;
    }

    update();
}

void MainWindow::volume_edit_loop_start_changed ( int val )
{
    if ( val >= 0 && val < volume_ed.current_envelope->loop_end )
    {
        volume_ed.current_envelope->loop_start = val;
    }

    update();
}

void MainWindow::volume_edit_loop_stop_changed ( int val )
{
    if ( val > volume_ed.current_envelope->loop_start && val < volume_ed.current_envelope->length )
    {
        volume_ed.current_envelope->loop_end = val;
    }

    update();
}

void MainWindow::volume_edit_loop_checked ( int val )
{
    if ( val == 0 )
    {
        volume_ed.current_envelope->loop = 0;
    }
    else
    {
        volume_ed.current_envelope->loop = 1;
    }

    update();
}

void MainWindow::volume_edit_duration_changed ( int val )
{
    volume_ed.current_envelope->duration[volume_ed.current_node] = val;

    update();
}

void MainWindow::volume_edit_value_changed ( int val )
{
    volume_ed.current_envelope->value[volume_ed.current_node] = ( ( float ) val ) / 255.0f;

    update();
}

void MainWindow::volume_edit_length_changed ( int val )
{
    if ( val <= 1 || val >= 7 )
    {
        update();
        return;
    }

    if ( val <= volume_ed.current_envelope->loop_end )
    {
        volume_ed.current_envelope->loop_end = val - 1;

        if ( volume_ed.current_envelope->loop_start >= volume_ed.current_envelope->loop_end )
        {
            volume_ed.current_envelope->loop_start = volume_ed.current_envelope->loop_end - 1;
        }
    }

    if ( val <= volume_ed.current_envelope->loop_start + 1 )
    {
        volume_ed.current_envelope->loop_start = val - 1;
    }

    volume_ed.current_envelope->length = val;

    update();
}

void MainWindow::pitch_edit_scale_changed ( int val )
{
    current_generator()->SetPitchScale ( ( float ) ( val*val*val ) / 4096.0f );

    update();
}

void MainWindow::pitch_edit_current_node_changed ( int val )
{
    if ( val >= 0 && val < pitch_ed.current_envelope->length )
    {
        pitch_ed.current_node = val;
    }

    update();
}

void MainWindow::pitch_edit_loop_start_changed ( int val )
{
    if ( val >= 0 && val < pitch_ed.current_envelope->loop_end )
    {
        pitch_ed.current_envelope->loop_start = val;
    }

    update();
}

void MainWindow::pitch_edit_loop_stop_changed ( int val )
{
    if ( val > pitch_ed.current_envelope->loop_start && val < pitch_ed.current_envelope->length )
    {
        pitch_ed.current_envelope->loop_end = val;
    }

    update();
}

void MainWindow::pitch_edit_loop_checked ( int val )
{
    if ( val == 0 )
    {
        pitch_ed.current_envelope->loop = 0;
    }
    else
    {
        pitch_ed.current_envelope->loop = 1;
    }

    update();
}

void MainWindow::pitch_edit_duration_changed ( int val )
{
    pitch_ed.current_envelope->duration[pitch_ed.current_node] = val;

    update();
}

void MainWindow::pitch_edit_value_changed ( int val )
{
    pitch_ed.current_envelope->value[pitch_ed.current_node] = ( ( float ) val ) / 255.0f;

    update();
}

void MainWindow::pitch_edit_length_changed ( int val )
{
    if ( val <= 1 || val >= 7 )
    {
        update();
        return;
    }

    if ( val <= pitch_ed.current_envelope->loop_end )
    {
        pitch_ed.current_envelope->loop_end = val - 1;

        if ( pitch_ed.current_envelope->loop_start >= pitch_ed.current_envelope->loop_end )
        {
            pitch_ed.current_envelope->loop_start = pitch_ed.current_envelope->loop_end - 1;
        }
    }

    if ( val <= pitch_ed.current_envelope->loop_start + 1 )
    {
        pitch_ed.current_envelope->loop_start = val - 1;
    }

    pitch_ed.current_envelope->length = val;

    update();
}

void MainWindow::filter_edit_current_node_changed ( int val )
{
    if ( val >= 0 && val < filter_ed.current_envelope->length )
    {
        filter_ed.current_node = val;
    }

    update();
}

void MainWindow::filter_edit_loop_start_changed ( int val )
{
    if ( val >= 0 && val < filter_ed.current_envelope->loop_end )
    {
        filter_ed.current_envelope->loop_start = val;
    }

    update();
}

void MainWindow::filter_edit_loop_stop_changed ( int val )
{
    if ( val > filter_ed.current_envelope->loop_start && val < filter_ed.current_envelope->length )
    {
        filter_ed.current_envelope->loop_end = val;
    }

    update();
}

void MainWindow::filter_edit_loop_checked ( int val )
{
    if ( val == 0 )
    {
        filter_ed.current_envelope->loop = 0;
    }
    else
    {
        filter_ed.current_envelope->loop = 1;
    }

    update();
}

void MainWindow::filter_edit_duration_changed ( int val )
{
    filter_ed.current_envelope->duration[filter_ed.current_node] = val;

    update();
}

void MainWindow::filter_edit_value_changed ( int val )
{
    filter_ed.current_envelope->value[filter_ed.current_node] = ( ( float ) val ) / 255.0f;

    update();
}

void MainWindow::filter_edit_resonance_changed ( int val )
{
    current_generator()->SetResonance(val);
}
void MainWindow::filter_edit_length_changed ( int val )
{
    if ( val <= 1 || val >= 7 )
    {
        update();
        return;
    }

    if ( val <= filter_ed.current_envelope->loop_end )
    {
        filter_ed.current_envelope->loop_end = val - 1;

        if ( filter_ed.current_envelope->loop_start >= filter_ed.current_envelope->loop_end )
        {
            filter_ed.current_envelope->loop_start = filter_ed.current_envelope->loop_end - 1;
        }
    }

    if ( val <= filter_ed.current_envelope->loop_start + 1 )
    {
        filter_ed.current_envelope->loop_start = val - 1;
    }

    filter_ed.current_envelope->length = val;

    update();
}

void MainWindow::octave_spin_changed ( int val )
{
    Generator::transpose_t transpose = current_generator()->GetTranspose();
    transpose.octave = val;
    current_generator()->SetTranspose ( transpose );
}

void MainWindow::semitone_spin_changed ( int val )
{
    Generator::transpose_t transpose = current_generator()->GetTranspose();
    transpose.semitone = val;
    current_generator()->SetTranspose ( transpose );
}

void MainWindow::finetune_spin_changed ( int val )
{
    Generator::transpose_t transpose = current_generator()->GetTranspose();
    transpose.finetune = val;
    current_generator()->SetTranspose ( transpose );
}

void MainWindow::voice_changed ( int voice )
{
    voice_ed.current_voice = voice;

    voice_list->setCurrentRow ( voice );
    redraw_generator();
    voice_name_lineedit->setText ( current_voice()->GetName() );
}

Generator* MainWindow::current_generator()
{
    return synth_container->GetVoice ( voice_ed.current_voice )->GetGenerator ( voice_ed.current_gen );
}

Voice* MainWindow::current_voice()
{
    return synth_container->GetVoice ( voice_ed.current_voice );
}

void MainWindow::base_func_changed ( int combo )
{
    switch ( combo )
    {
        case 0:
            current_generator()->SetBaseFunc ( Generator::GEN_SINE );
            break;
        case 1:
            current_generator()->SetBaseFunc ( Generator::GEN_SAW );
            break;
        case 2:
            current_generator()->SetBaseFunc ( Generator::GEN_SQUARE );
            break;
        case 3:
            current_generator()->SetBaseFunc ( Generator::GEN_POW );
            break;
        case 4:
            current_generator()->SetBaseFunc ( Generator::GEN_GAUSS );
            break;
    }
}

void MainWindow::render_clicked()
{
    current_generator()->RenderWavetable();
}

void MainWindow::set_harmonic ( int harmonic, int value )
{
    current_generator()->SetHarmonic ( harmonic, value );
}

void MainWindow::set_generator ( int generator )
{
    voice_ed.current_gen = generator;
    redraw_generator();
}

void MainWindow::enable_gen ( int state )
{
    if ( state == Qt::Checked )
    {
        current_generator()->SetEnabled ( 1 );
        cout << "Setting " << voice_ed.current_gen << " to " << "1" << endl;
    }
    else
    {
        current_generator()->SetEnabled ( 0 );
        cout << "Setting " << voice_ed.current_gen << " to " << "0" << endl;
    }
}

void MainWindow::redraw_generator()
{
    if ( current_generator()->Enabled() )
    {
        gen_enable->setCheckState ( Qt::Checked );
    }
    else
    {
        gen_enable->setCheckState ( Qt::Unchecked );
    }


    harmonic1->setSliderPosition ( current_generator()->GetHarmonic ( 0 ) );

    harmonic2->setSliderPosition ( current_generator()->GetHarmonic ( 1 ) );
    harmonic3->setSliderPosition ( current_generator()->GetHarmonic ( 2 ) );
    harmonic4->setSliderPosition ( current_generator()->GetHarmonic ( 3 ) );
    harmonic5->setSliderPosition ( current_generator()->GetHarmonic ( 4 ) );
    harmonic6->setSliderPosition ( current_generator()->GetHarmonic ( 5 ) );
    harmonic7->setSliderPosition ( current_generator()->GetHarmonic ( 6 ) );
    harmonic8->setSliderPosition ( current_generator()->GetHarmonic ( 7 ) );

    update();

    switch ( current_generator()->GetBaseFunc() )
    {
        case Generator::GEN_SINE:
            base_func_combo->setCurrentIndex ( 0 );
            break;
        case Generator::GEN_SAW:
            base_func_combo->setCurrentIndex ( 1 );
            break;
        case Generator::GEN_SQUARE:
            base_func_combo->setCurrentIndex ( 2 );
            break;
        case Generator::GEN_POW:
            base_func_combo->setCurrentIndex ( 3 );
            break;
        case Generator::GEN_GAUSS:
            base_func_combo->setCurrentIndex ( 4 );
            break;
        case Generator::GEN_NOISE:
            break;
    }

    Generator::transpose_t transpose = current_generator()->GetTranspose();

    octave_spin->setValue ( transpose.octave );
    semitone_spin->setValue ( transpose.semitone );
    finetune_spin->setValue ( transpose.finetune );

    delay_left_delay_slider->setValue ( current_voice()->GetDelayAmount ( 0 ) / 1000);
    delay_right_delay_slider->setValue ( current_voice()->GetDelayAmount ( 1 )  / 1000);
    delay_left_feedback_slider->setValue ( current_voice()->GetDelayFeedback ( 0 ) * 100.0f );
    delay_right_feedback_slider->setValue ( current_voice()->GetDelayFeedback ( 1 ) * 100.0f );
    gain_left_slider->setValue ( current_voice()->GetGain ( 0 ) );
    gain_right_slider->setValue ( current_voice()->GetGain ( 1 ) );
    reverb_send_slider->setValue ( current_voice()->GetReverbSend() * 100.0f );
    cout << current_voice()->GetReverbSend() << endl;
    distortion_threshold_slider->setValue ( current_voice()->GetDistortionThreshold() );
}


void MainWindow::OpenSong()
{
//    releaseKeyboard();
    QString filename = QFileDialog::getOpenFileName ( 0, "Choose file to load song from", "", "Mapprox Songs (*.mprx)" );

    if ( !filename.isNull() )
    {
        BitBuffer buffer ( ( const char* ) filename.toAscii() );
        synth_container->LoadData ( buffer );
        song_filename = filename;
    }

//    grabKeyboard();
}


void MainWindow::SaveAs()
{
//    releaseKeyboard();
    QString filename = QFileDialog::getSaveFileName ( 0, "Choose filename to save song to", "", "Mapprox Songs (*.mprx)" );

    if ( !filename.isNull() )
    {
        if ( filename.right ( 5 ) != ".mprx" )
            filename += ".mprx";

        BitBuffer buffer;

        
        synth_container->PushData ( buffer );

        buffer.Save ( filename.toAscii() );

        song_filename = filename;
    }

//    grabKeyboard();
}

void MainWindow::SaveSong()
{
    if ( song_filename == QString ( "" ) )
        SaveAs();
    else
    {
        BitBuffer buffer;
        synth_container->PushData ( buffer );
        buffer.Save ( song_filename.toAscii() );
    }
}

void MainWindow::delay_left_delay_slider_changed ( int val )
{
    current_voice()->SetDelayAmount ( 0, val * 1000);
}

void MainWindow::delay_right_delay_slider_changed ( int val )
{
    current_voice()->SetDelayAmount ( 1, val * 1000);
}

void MainWindow::delay_left_feedback_slider_changed ( int val )
{
    current_voice()->SetDelayFeedback ( 0, ( float ) val / 100.0 );
}

void MainWindow::delay_right_feedback_slider_changed ( int val )
{
    current_voice()->SetDelayFeedback ( 1, ( float ) val / 100.0 );
}

void MainWindow::gain_left_slider_changed ( int val )
{
    current_voice()->SetGain ( 0, val );
}

void MainWindow::gain_right_slider_changed ( int val )
{
    current_voice()->SetGain ( 1, val );
}

void MainWindow::reverb_send_slider_changed ( int val )
{
    current_voice()->SetReverbSend ( ( float ) val / 100.0f );
}

void MainWindow::distortion_threshold_slider_changed ( int val )
{
    current_voice()->SetDistortionThreshold ( val );
}

void Mapprox::MainWindow::keyPressEvent ( QKeyEvent * e )
{
    if ( voice_name_lineedit->hasFocus() )
    {
        if ( e->key() == Qt::Key_Return || e->key() == Qt::Key_Enter )
        {
            this->setFocus();
        }

        voice_name_lineedit->event ( e );

        return;
    }
}

void Mapprox::MainWindow::keyReleaseEvent ( QKeyEvent * e )
{
}


/*!
    \fn Mapprox::MainWindow::play_song()
 */
void Mapprox::MainWindow::PlaySong()
{
    synth_container->PlaySong();
}


/*!
    \fn Mapprox::MainWindow::play_stop()
 */
void Mapprox::MainWindow::Stop()
{
    synth_container->Stop();
}

void Mapprox::MainWindow::RecordSong()
{
    synth_container->RecordSong();
}
