#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup()
{
    ofBackground(0);
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
            int tempHue = m.getArgAsInt(1);
            int tempSat = m.getArgAsInt(2);
            int tempBri = m.getArgAsInt(3);

            hue[index] = tempHue;
            saturation[index] = tempSat;
            bright[index] = tempBri;
            //   std::cout << "get item: " << index << ", v1: " << value1 << ", v2: " << value2 << std::endl;
            if (index == numItems - 1)
            {
                arrayComplete = true;
                for (int i = 0; i < numItems; i++)
                {
                    blobVector.push_back(splash(500, 100, hue[i], saturation[i], bright[i]));
                }
            }

            // if (arrayComplete){
            //     for (int i = 0; i < numNotes; i++)
            //     {
            //         std::cout << i << ": " << hue[i] << ", ";
            //     }
            //     std::cout << std::endl;
            //     arrayComplete = false;
            // }
        }

        if ( (m.getAddress() == "/positions") && arrayComplete)
        {
            int index = m.getArgAsInt(0);
            int position = m.getArgAsInt(1);

            blobVector[index].xpos = ofMap(position, -1, 1, BORDER, ofGetWidth()-BORDER);
            blobVector[index].ypos = ofMap(position, -1, 1, BORDER, ofGetHeight()-BORDER);
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
