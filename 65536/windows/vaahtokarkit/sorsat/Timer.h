#ifndef _Timer_h_
#define _Timer_h_

class Timer
{
public:
    Timer(int tps=100);
    void start(int tps);
    int getCounter();
    float getCounterf();
    int getSpeed();
    void setCounter(int c);

private:
    float multijuttu;
    int start_time,tps;
};

#endif                            
