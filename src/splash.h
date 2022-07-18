#ifndef SPLASH_H
#define SPLASH_H

#include "ofMain.h"

class splash
{
public:
     
    splash();
    splash(float size, float points, int hue, int sat, int bright);
    ~splash(); 
    int xpos;
    int ypos;
    void setPoints(int points){m_points = points;};
    void setSize(int size){m_size = size;};
    
    void draw();

private:
    float m_size;
    float m_points;
    int m_hue, m_sat, m_bright;
    float m_yoff, m_xoff;
    float m_increment;
    ofColor m_color;


};

#endif