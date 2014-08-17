#ifndef GTBLAYERBASE_H
#define GTBLAYERBASE_H
//
//  OOLayerBase.h
//  GTB
//
//  Created by Gary Wong on 6/24/13.
//  Copyright 2013 Oriole2 Co., Ltd. All rights reserved.
//

#include "cocos2d.h"
#include "cocos-ext.h"

USING_NS_CC;
USING_NS_CC_EXT;

#define kCCBaseProtocol \
virtual SEL_CCControlHandler onResolveCCBCCControlSelector(CCObject *pTarget, const char *pSelectorName); \
virtual bool onAssignCCBMemberVariable(CCObject *pTarget, const char *pMemberVariableName, CCNode *pNode); \
virtual void onNodeLoaded(cocos2d::CCNode *pNode, CCNodeLoader *pNodeLoader);

#define kMenuHandler \
virtual SEL_MenuHandler onResolveCCBCCMenuItemSelector(CCObject *pTarget, const char *pSelectorName);

#define kAppearAnimationName "appear"
#define kDisappearAnimationName "disappear"

#define kAnimationManagerDelegate \
virtual void completedAnimationSequenceNamed(const char *name);

/*
 若Layer不需要加载其他自定义类则头文件中使用宏kCreateLayerFromCCB
 实现文件中声明宏kCreateLayerFromCCBImplement即可
 
 LAYERTYPE --- 仅仅使用类名，请不要加后面的*
 */
#define kCreateLayerFromCCB(LAYERTYPE) \
static LAYERTYPE* createLayerFromCCB(); \
static void createLayerFromCCBExternMethod(CCNodeLoaderLibrary* nll){};

#define kCreateLayerFromCCBImplement(LAYERTYPE, LAYERTYPENAME, LAYERTYPELOADER, LAYERTYPECCBINAME) kCreateLayerFromCCBImplementWithExternMethodOption(LAYERTYPE, LAYERTYPENAME, LAYERTYPELOADER, LAYERTYPECCBINAME, false)

/*
 若Layer需要加载其他自定义类则头文件中使用宏kCreateLayerFromCCBWithExternMethod
 配合kCreateLayerFromCCBImplementWithExternMethodBegin/kCreateLayerFromCCBImplementWithExternMethodEnd在实现文件中包含加载自定义类的逻辑
 被包含的代码已获得nll（CCNodeLoaderLibrary*）可以直接使用
 例如：nll->registerCCNodeLoader("EXTurnCard", EXTurnCardLoader::loader());
 
 LAYERTYPE --- 仅仅使用类名，请不要加后面的*
 */
#define kCreateLayerFromCCBWithExternMethod(LAYERTYPE) \
static LAYERTYPE* createLayerFromCCB(); \
static void createLayerFromCCBExternMethod(CCNodeLoaderLibrary* nll);

#define kCreateLayerFromCCBImplementWithExternMethodBegin(LAYERTYPE, LAYERTYPENAME, LAYERTYPELOADER, LAYERTYPECCBINAME) \
kCreateLayerFromCCBImplementWithExternMethodOption(LAYERTYPE, LAYERTYPENAME, LAYERTYPELOADER, LAYERTYPECCBINAME, true) \
void LAYERTYPE::createLayerFromCCBExternMethod(CCNodeLoaderLibrary* nll) \
{

#define kCreateLayerFromCCBImplementWithExternMethodEnd }

/*
 请不要直接使用宏kCreateLayerFromCCBImplementWithExternMethodOption
 这是配合kCreateLayerFromCCBImplement/Begin/End使用的辅助宏
 */
#define kCreateLayerFromCCBImplementWithExternMethodOption(LAYERTYPE, LAYERTYPENAME, LAYERTYPELOADER, LAYERTYPECCBINAME, bCUSTOMEXTERNMETHOD) \
LAYERTYPE* LAYERTYPE::createLayerFromCCB() \
{ \
CCNodeLoaderLibrary* nll = CCNodeLoaderLibrary::sharedCCNodeLoaderLibrary(); \
if (bCUSTOMEXTERNMETHOD) \
createLayerFromCCBExternMethod(nll); \
nll->registerCCNodeLoader(LAYERTYPENAME, LAYERTYPELOADER::loader()); \
CCBReader* ccbReader = new CCBReader(nll); \
LAYERTYPE* layer = (LAYERTYPE*)ccbReader->readNodeGraphFromFile(LAYERTYPECCBINAME); \
layer->setAnimationManager(ccbReader->getAnimationManager()); \
delete ccbReader; \
return layer; \
}

/*
 宏kCreateSceneFromCCB在头文件中声明，需要与宏kCreateLayerFromCCB或同类宏搭配使用
 
 LAYERTYPE --- 仅仅使用类名，请不要加后面的*
 */
#define kCreateSceneFromCCB(LAYERTYPE) \
static CCScene* createSceneFromCCB() \
{ \
LAYERTYPE* layer = createLayerFromCCB(); \
CCScene* scene = CCScene::create(); \
scene->addChild(layer); \
return scene; \
}

class OOLayerBase: public CCLayer
, public CCBSelectorResolver
, public CCBMemberVariableAssigner
, public CCNodeLoaderListener
, public CCBAnimationManagerDelegate
{
public:
    OOLayerBase();
    virtual ~OOLayerBase();
    
    kCCBaseProtocol;
    kMenuHandler;
    kAnimationManagerDelegate;
    
    void setAnimationManager(CCBAnimationManager *pAnimationManager);
    CCBAnimationManager *getAnimationManager();
    
private:
    CCBAnimationManager *mAnimationManager;
};

#endif //GTBLAYERBASE_H