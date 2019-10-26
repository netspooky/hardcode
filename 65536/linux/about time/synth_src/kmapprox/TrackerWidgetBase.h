/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef MAPPROXTRACKERWIDGETBASE_H
#define MAPPROXTRACKERWIDGETBASE_H

#include <QWidget>

namespace Mapprox {

class TrackerWidgetBase : public QWidget
{
Q_OBJECT
public:
    TrackerWidgetBase(QWidget *parent = 0);

    ~TrackerWidgetBase();

};

}

#endif
