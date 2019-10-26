/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef MAPPROXVOICEGRAPHWIDGET_H
#define MAPPROXVOICEGRAPHWIDGET_H

#include <QWidget>

namespace Mapprox {

class VoiceGraphWidget : public QWidget
{
Q_OBJECT
public:
    VoiceGraphWidget(QWidget *parent = 0);

    ~VoiceGraphWidget();
signals:
    void resized();
    void paintevent();
public:
    void resizeEvent(QResizeEvent* event);
    void paintEvent(QPaintEvent* event);
};

}

#endif
