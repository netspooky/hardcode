/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef MAPPROXTRACKERINDEXWIDGET_H
#define MAPPROXTRACKERINDEXWIDGET_H

#include <QWidget>
#include "TrackerWidgetBase.h"

namespace Mapprox {

class TrackerIndexWidget : public TrackerWidgetBase
{
Q_OBJECT
public:
    TrackerIndexWidget(QWidget *parent = 0);

    ~TrackerIndexWidget();

};

}

#endif
