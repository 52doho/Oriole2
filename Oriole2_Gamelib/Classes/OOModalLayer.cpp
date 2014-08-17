//
//  OOModalLayer.m
//  GTB
//
//  Created by Gary Wong on 6/24/13.
//  Copyright 2013 Oriole2 Co., Ltd. All rights reserved.
//

#include "OOModalLayer.h"

OOModalLayer::OOModalLayer():delegate(NULL)
{
}

OOModalLayer::~OOModalLayer()
{
}

void OOModalLayer::onEnter()
{
    OOLayerBase::onEnter();
    
    this->priority = kCCMenuHandlerPriority - 1;
    this->setTouchEnabled(true);
}

void OOModalLayer::onExit()
{
    OOLayerBase::onExit();
    
    if(delegate)
        delegate->modelLayerOnExit(this);
}

SEL_CCControlHandler OOModalLayer::onResolveCCBCCControlSelector(CCObject *pTarget, const char *pSelectorName)
{
    return OOLayerBase::onResolveCCBCCControlSelector(pTarget, pSelectorName);
}

bool OOModalLayer::onAssignCCBMemberVariable(CCObject *pTarget, const char *pMemberVariableName, CCNode *pNode)
{
    return OOLayerBase::onAssignCCBMemberVariable(pTarget, pMemberVariableName, pNode);
}

void OOModalLayer::onNodeLoaded(CCNode *pNode, CCNodeLoader *pNodeLoader)
{
    OOLayerBase::onNodeLoaded(pNode, pNodeLoader);
    
}

void OOModalLayer::registerWithTouchDispatcher()
{
    CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this, this->priority, true);
}

bool OOModalLayer::_containsTouchableControlInNode(CCNode * node, CCTouch * touch)
{
    if (node != NULL)
    {
        CCObject *subNode;
        CCARRAY_FOREACH(node->getChildren(), subNode)
        {
            bool isCB = dynamic_cast<CCControlButton*>(subNode) ? true : false;
            bool isMI = dynamic_cast<CCMenuItem*>(subNode) ? true : false;
            
            CCNode *innerNode = dynamic_cast<CCNode *>(subNode);
            
            if (isCB || isMI)
            {
                // eat all touches outside of control
                CCRect frame = innerNode->boundingBox();
                CCPoint touchLocation = node->convertTouchToNodeSpace(touch);
                bool contains = frame.containsPoint(touchLocation);
                if(contains)
                    return true;
            }
            bool contains = this->_containsTouchableControlInNode(innerNode , touch);
            if(contains)
                return true;
        }
    }
    return false;
}

bool OOModalLayer::ccTouchBegan(CCTouch * touch, CCEvent * event)
{
    if(!this->isVisible())
        return false;
    
    bool contains = this->_containsTouchableControlInNode(this , touch);
    return !contains;
}

bool OOModalLayer::_containsNonLayerColorInNode(CCNode * node, CCTouch * touch, unsigned int depth)
{
    if (node != NULL)
    {
        CCObject *subNode;
        CCARRAY_FOREACH(node->getChildren(), subNode)
        {
            CCNode *innerNode = dynamic_cast<CCNode *>(subNode);
            
//            std::string str = "";
//            unsigned int i = depth;
//            while (i > 0)
//            {
//                str.append("---");
//                i--;
//            }
//            CCLOG("%s %s", str.c_str(), innerNode->description());// typeid(subNode).name());//not work
            bool isLayerColor = dynamic_cast<CCLayerColor*>(subNode) ? true : false;
            if (!isLayerColor)
            {
                // eat all touches outside of control
                CCRect frame = innerNode->boundingBox();
                CCPoint touchLocation = node->convertTouchToNodeSpace(touch);
                bool contains = frame.containsPoint(touchLocation);
                if(contains)
                    return true;
            }
            bool contains = this->_containsNonLayerColorInNode(innerNode , touch, depth + 1);
            if(contains)
                return true;
        }
    }
    return false;
}

void OOModalLayer::ccTouchEnded(CCTouch *touch, CCEvent *pEvent)
{
    bool contains = this->_containsNonLayerColorInNode(this , touch, 0);
    if(!contains)
    {
        tapOnLayerColor();
    }
}

void OOModalLayer::tapOnLayerColor()
{
    
}
