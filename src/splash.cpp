#include "splash.h"

splash::splash()
{
    m_size = 200;
    m_points = 100;
    m_hue = 0;
    m_sat = 255;
    m_bright = 42;
    xpos = ofGetWidth()/2;
    ypos = ofGetHeight()/2;
    m_xoff = 0;
    m_yoff = 0;
    m_color.setHsb(m_hue, m_sat, m_bright); 
    m_increment = TWO_PI/m_points;

}

splash::splash(float size, float points, int hue, int sat, int bright)
    : m_size{size}, m_points{points}, m_hue{hue}, m_sat{sat}, m_bright{bright}
    {
        xpos = ofGetWidth()/2;
        ypos = ofGetHeight()/2;
        m_xoff = 0;
        m_yoff = 0;
        m_color.setHsb(m_hue, m_sat, m_bright); 
        m_increment = TWO_PI/m_points;

        // std::cout << "creating blob (size, points, hue, sat, bright):  " 
        // << m_size << ", "
        // << m_points << ", "
        // << m_hue << ", "
        // << m_sat << ", "
        // << m_bright << ", " << std::endl;
    }


void splash::draw(){


    ofPushMatrix();
    ofTranslate(xpos, ypos);
    ofFill();
    m_color.setHsb(m_hue, m_sat, m_bright, 200); 
    ofSetColor(m_color);

    ofBeginShape();
    m_xoff = 0.0f;
    for (float a = 0; a < TWO_PI; a += m_increment) {
        float offset = ofMap(ofNoise(m_xoff, m_yoff), 0, 1, -25, 25);
    float r = m_size + offset;
    float x = r * std::cos(a);
    float y = r * std::sin(a);
    ofVertex(x, y);
    m_xoff += 0.3;

  }
  ofEndShape();

  m_yoff += 0.01;
  ofPopMatrix();

}

splash::~splash()
{

}