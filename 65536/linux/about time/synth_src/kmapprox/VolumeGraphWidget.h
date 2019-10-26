/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef __VOLUME_GRAPH_WIDGET_H
#define __VOLUME_GRAPH_WIDGET_H

#include <QWidget>

namespace Mapprox {

class VolumeGraphWidget : public QWidget
{
    Q_OBJECT
public:
    VolumeGraphWidget(QWidget *parent = 0);

    ~VolumeGraphWidget();
signals:
    void resized();
    void paintevent();
public:
    void resizeEvent(QResizeEvent* event);
    void paintEvent(QPaintEvent* event);
};

}

#endif // __VOLUME_GRAPH_WIDGET_H
