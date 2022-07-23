#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup()
{
    ofBackground(0);
    receiver.setup(12345);
}

//--------------------------------------------------------------
void ofApp::update()
{
    while (receiver.hasWaitingMessages())
    {
        ofxOscMessage m;
        receiver.getNextMessage(m);

     

        if (m.getAddress() == "/setup/size")
        {
            arrayComplete = false;
            blobVector.clear();
            hue.clear();
            saturation.clear();
            bright.clear();
            position.clear();

            numItems = m.getArgAsInt(0);

            std::cout << "getting number of itens: " << numItems << std::endl;
                
            for (int i = 0; i < numItems; i++)
            {
                hue.push_back(0);
                saturation.push_back(0);
                bright.push_back(0);
                position.push_back(0);
            }
        }

        if (m.getAddress() == "/colors")
        {
            int index = m.getArgAsInt(0);
            float tempHue = m.getArgAsFloat(1);
            float tempSat = m.getArgAsFloat(2);
            float tempBri = m.getArgAsFloat(3);

            hue[index] = tempHue;
            saturation[index] = tempSat;
            bright[index] = tempBri;
            //   std::cout << "get item: " << index << ", v1: " << value1 << ", v2: " << value2 << std::endl;
            if (index == numItems - 1)
            {
                arrayComplete = true;
                for (int i = 0; i < numItems; i++)
                {
                    int size = ofRandom(50,300);
                    blobVector.push_back(splash(size, 100, hue[i], saturation[i], bright[i]));
                    blobVector[i].ypos = ofMap(ofRandom(0,1), 0, 1, BORDER, ofGetHeight()-BORDER);
                }
            }
        }

        if (m.getAddress() == "/updateNote"){            
            int index = m.getArgAsInt(0);
            float tempHue = m.getArgAsFloat(1);
            float tempSat = m.getArgAsFloat(2);
            float tempBri = m.getArgAsFloat(3);

            hue[index] = tempHue;
            saturation[index] = tempSat;
            bright[index] = tempBri;

            blobVector[index].setHue(tempHue);
            blobVector[index].setSaturation(tempSat);
            blobVector[index].setBright(tempBri);

        }

        if ( (m.getAddress() == "/positions") && arrayComplete)
        {
            int index = m.getArgAsFloat(0);
            float position = m.getArgAsFloat(1);

            blobVector[index].xpos = ofMap(position, -1.0f, 1.0f, BORDER, ofGetWidth()-BORDER);
          //  blobVector[index].ypos = ofMap(ofRandom(-1.0,position), -1.0f, 1.0f, BORDER, ofGetHeight()-BORDER);
        }
    }
}

//--------------------------------------------------------------
void ofApp::draw()
{

    for (int i = 0; i < numItems; i++)
    {
        blobVector[i].draw();
    }
    
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key)
{
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key)
{
}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y)
{
}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button)
{
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button)
{
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button)
{
}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y)
{
}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y)
{
}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h)
{
}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg)
{
}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo)
{
}
