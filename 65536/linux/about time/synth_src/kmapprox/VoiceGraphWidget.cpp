/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#include "VoiceGraphWidget.h"

namespace Mapprox {

VoiceGraphWidget::VoiceGraphWidget(QWidget *parent)
 : QWidget(parent)
{
}


VoiceGraphWidget::~VoiceGraphWidget()
{
}

void VoiceGraphWidget::resizeEvent(QResizeEvent* event)
{
    emit resized();
}

void VoiceGraphWidget::paintEvent(QPaintEvent* event)
{
    emit paintevent();
}

}
