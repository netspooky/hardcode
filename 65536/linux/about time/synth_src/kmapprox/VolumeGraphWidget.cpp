/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#include "VolumeGraphWidget.h"

namespace Mapprox {

VolumeGraphWidget::VolumeGraphWidget(QWidget *parent)
    : QWidget(parent)
{
}


VolumeGraphWidget::~VolumeGraphWidget()
{
}

void VolumeGraphWidget::resizeEvent(QResizeEvent* event)
{
    emit resized();
}

void VolumeGraphWidget::paintEvent(QPaintEvent* event)
{
    emit paintevent();
}

}

