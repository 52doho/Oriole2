//
//  ShatteredSprite.cpp
//
//  Created by SuperSuRaccoon on 12/8/12.
//
//

#ifndef ShatteredSprite_h
#define ShatteredSprite_h

#include "cocos2d.h"


//Can change this for what's really used...or really could alloc the memory too
//200 works for a 10x10 grid (with 2 triangles per square)
//128 = 8x8 *2
//98  = 7x7 *2
//64  = 6x6 *2
//50  = 5x5 *2
//32  = 4x4 *2
#define SHATTER_VERTEX_MAX    128

#ifndef DEFTriangleVertices
//Helper things, since it moves the triangles separately
typedef struct _TriangleVertices {
    cocos2d::CCPoint        pt1;
    cocos2d::CCPoint        pt2;
    cocos2d::CCPoint        pt3;
} TriangleVertices;

static inline TriangleVertices
tri(cocos2d::CCPoint pt1, cocos2d::CCPoint pt2, cocos2d::CCPoint pt3) {
    TriangleVertices t;
    t.pt1 = pt1; t.pt2 = pt2; t.pt3 = pt3;
    //= {pt1, pt2, pt3 };
    return t;
}

typedef struct _TriangleColors {
    cocos2d::ccColor4B        c1;
    cocos2d::ccColor4B        c2;
    cocos2d::ccColor4B        c3;
} TriangleColors;
#define DEFTriangleVertices
#endif


//Subclass of CCSprite, so all the color & opacity things work by just overriding updateColor, and can use the sprite's texture too.
class ShatteredSprite : public cocos2d::CCSprite
{
    
public:
    ShatteredSprite();
    ~ShatteredSprite();
    
    static ShatteredSprite* shatterWithSprite(cocos2d::CCSprite *sprite, int px, int py, float speedVar, float rotation, bool radial);
    bool initWithSprite(cocos2d::CCSprite *sprite, int px, int py, float speedVar, float rotation, bool radial);
    void shatterSprite(cocos2d::CCSprite *sprite, int px, int py, float speedVar, float rotation, bool radial);
    void subShatter();
    void shadowedPieces();
    
    virtual void draw();
    
    
    void updateColor(void);
    
    CC_SYNTHESIZE(int, subShatterPercent, cc_subShatterPercent)
    CC_SYNTHESIZE(cocos2d::CCPoint, gravity, cc_gravity)
    
private:
    void update(float dt);
    
private:
    TriangleVertices    vertices[SHATTER_VERTEX_MAX];
    TriangleVertices    shadowVertices[SHATTER_VERTEX_MAX];
    TriangleVertices    texCoords[SHATTER_VERTEX_MAX];
    TriangleColors        colorArray[SHATTER_VERTEX_MAX];
    
    float                adelta[SHATTER_VERTEX_MAX];
    cocos2d::CCPoint    vdelta[SHATTER_VERTEX_MAX];
    cocos2d::CCPoint    centerPt[SHATTER_VERTEX_MAX];
    
    float                shatterSpeedVar, shatterRotVar;
    int                    numVertices;
    //    int                    subShatterPercent;
    bool                radial;
    bool                slowExplosion;
    int                    fallOdds, fallPerSec;
    //  cocos2d::CCPoint    gravity;
    bool                shadowed;
    cocos2d::CCTexture2D            *shadowTexture;
};
#endif

