#include "ShatteredSprite.h"

USING_NS_CC;

#ifndef RANDF
//A helper to do float random numbers in a range around a base value.
float randf(float base, float range) {
    if (range==0) return base;
    long        lRange = rand()%(int)((range*2)*10000);
    float        fRange = ((float)lRange/10000.0) - range;
    return    base + fRange;
}
#endif

ShatteredSprite::ShatteredSprite()
{
    shatterSpeedVar = 0;
    shatterRotVar = 0;
    numVertices = 0;
    radial = false;
    slowExplosion = false;
    fallOdds = 0;
    fallPerSec = 0;
    shadowed = false;
    shadowTexture = NULL;
    subShatterPercent = 0;
    gravity = ccp(0,0);
    
    for(int i=0; i<SHATTER_VERTEX_MAX; i++)
    {
        vertices[i].pt1 = ccp(0,0);
        vertices[i].pt2 = ccp(0,0);
        vertices[i].pt3 = ccp(0,0);
        
        shadowVertices[i].pt1 = ccp(0,0);
        shadowVertices[i].pt2 = ccp(0,0);
        shadowVertices[i].pt3 = ccp(0,0);
        
        texCoords[i].pt1 = ccp(0,0);
        texCoords[i].pt2 = ccp(0,0);
        texCoords[i].pt3 = ccp(0,0);
        
        colorArray[i].c1 = ccc4(0, 0, 0, 0);
        colorArray[i].c2 = ccc4(0, 0, 0, 0);
        colorArray[i].c3 = ccc4(0, 0, 0, 0);
        
        adelta[i] = 0;
        vdelta[i] = ccp(0,0);
        centerPt[i] = ccp(0,0);
    }
}

ShatteredSprite::~ShatteredSprite()
{
    CC_SAFE_RELEASE(shadowTexture);
}

ShatteredSprite* ShatteredSprite::shatterWithSprite(cocos2d::CCSprite *sprite, int piecesX, int piecesY, float speedVar, float rotVar, bool radialIn)
{
    ShatteredSprite *pRet = new ShatteredSprite;
    pRet->initWithSprite(sprite, piecesX, piecesY, speedVar, rotVar, radialIn);
    pRet->autorelease();
    return pRet;
}

bool ShatteredSprite::initWithSprite(cocos2d::CCSprite *sprite, int piecesX, int piecesY, float speedVar, float rotVar, bool radialIn)
{
    if(CCSprite::init())
    {
        // Initialization code here.
        slowExplosion = false;
        radial = radialIn;
        shatterSprite(sprite, piecesX, piecesY, speedVar, rotVar, radialIn);
        subShatterPercent = 0;
        scheduleUpdate();
        return true;
    }
    return false;
}

void ShatteredSprite::update(float dt)
{
    //Note, does NOT adjust vdelta and adelta for slow frames;
    //To do that, need some d=(delta*60.0) that's multiplied by the vdelta and adelta
    for (int i = 0; i<numVertices; i++) {
        vertices[i].pt1 = ccpAdd(vertices[i].pt1, vdelta[i]);
        vertices[i].pt2 = ccpAdd(vertices[i].pt2, vdelta[i]);
        vertices[i].pt3 = ccpAdd(vertices[i].pt3, vdelta[i]);
        centerPt[i] = ccpAdd(centerPt[i], vdelta[i]);
        
        vertices[i].pt1 = ccpRotateByAngle(vertices[i].pt1, centerPt[i], adelta[i]);
        vertices[i].pt2 = ccpRotateByAngle(vertices[i].pt2, centerPt[i], adelta[i]);
        vertices[i].pt3 = ccpRotateByAngle(vertices[i].pt3, centerPt[i], adelta[i]);
        
        if (slowExplosion) {
            if (adelta[i]==0 && vdelta[i].x==0 && vdelta[i].y==0 && rand()%fallOdds==0) {
                //Increases the odds each time
                if (fallOdds>fallPerSec) fallOdds -= fallPerSec;
                vdelta[i] = ccp(randf(0.0, shatterSpeedVar), randf(0.0, shatterSpeedVar));
                adelta[i] = randf(0.0, shatterRotVar);
            }
            if (vdelta[i].x!=0 || vdelta[i].y!=0) {
                vdelta[i] = ccpAdd(vdelta[i], gravity);
            }
        }
    }
    if (rand()%100<subShatterPercent)
        subShatter();
}

void ShatteredSprite::draw()
{
	CC_ENABLE_DEFAULT_GL_STATES();
    
    glBindTexture(GL_TEXTURE_2D, m_pobTexture->getName());
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colorArray);
	glDrawArrays(GL_TRIANGLES, 0, numVertices*3);
}

void ShatteredSprite::updateColor()
{
    //Update the color array...
    ccColor4B color4 = { m_sColor.r, m_sColor.g, m_sColor.b, m_nOpacity };
    TriangleColors    triColor4 = { color4, color4, color4 };
    for (int i=0; i<numVertices; i++) {
        colorArray[i] = triColor4;
    }
}

void ShatteredSprite::shadowedPieces()
{
    CCRenderTexture    *tex = CCRenderTexture::renderTextureWithWidthAndHeight(64, 64); //[CCRenderTexture renderTextureWithWidth:64 height:64];
    shadowed = true;
    
    tex->beginWithClear(0, 0, 0, 0.25);
    tex->end();
    shadowTexture = tex->getSprite()->getTexture();
    shadowTexture->retain();
}

void ShatteredSprite::subShatter()
{
    int i = rand()%numVertices;
    if (numVertices>=SHATTER_VERTEX_MAX-1) return;
    TriangleVertices    v1 = vertices[i];
    TriangleVertices    t1 = texCoords[i];
    
    if (rand()%100<75) {
        //Split along the LONGEST edge most of the time
        float    d12 = ccpLengthSQ(ccpSub(v1.pt1, v1.pt2));
        float    d23 = ccpLengthSQ(ccpSub(v1.pt2, v1.pt3));
        float    d31 = ccpLengthSQ(ccpSub(v1.pt3, v1.pt1));
        if (d12>d23 && d12>d31) {
            v1 = tri(v1.pt2, v1.pt3, v1.pt1);
            t1 = tri(t1.pt2, t1.pt3, t1.pt1);
        } else if (d23>d12 && d23>d31) {
            v1 = tri(v1.pt3, v1.pt1, v1.pt2);
            t1 = tri(t1.pt3, t1.pt1, t1.pt2);
        }
    } else {
        //ROTATES the vertex and texture things, to do along a random axis sometimes
        while (rand()%3==0) {
            v1 = tri(v1.pt2, v1.pt3, v1.pt1);
            t1 = tri(t1.pt2, t1.pt3, t1.pt1);
        }
    }
    
    //Update the original one.
    vertices[i] = tri(ccpMidpoint(v1.pt1, v1.pt3), v1.pt2, v1.pt3);
    
    centerPt[i] = ccp((vertices[i].pt1.x + vertices[i].pt2.x + vertices[i].pt3.x)/3.0,
                   (vertices[i].pt1.y + vertices[i].pt2.y + vertices[i].pt3.y)/3.0);
    
    texCoords[i] = tri(ccpMidpoint(t1.pt1, t1.pt3), t1.pt2, t1.pt3);
    
    //Shattering again changes it's rotation & direction
    CCPoint    originalVDelta = vdelta[i];
    if (radial) {
        vdelta[i] = ccp(randf(originalVDelta.x, shatterSpeedVar/4.0), randf(originalVDelta.y, shatterSpeedVar/4.0));
    } else {
        vdelta[i] = ccp(randf(0.0, shatterSpeedVar), randf(0.0, shatterSpeedVar));
    }
    adelta[i] = randf(0.0, shatterRotVar);
    
    //Shift up to insert the new one in the next spot.
    //So overlapping things look right--ones behind break and don't jump forward.
    numVertices++;
    for (int j=numVertices-1; j>i+1; j--) {
        vdelta[j] = vdelta[j-1];
        adelta[j] = adelta[j-1];
        colorArray[j] = colorArray[j-1];
        
        vertices[j] = vertices[j-1];
        centerPt[j] = centerPt[j-1];
        texCoords[j] = texCoords[j-1];
    }
    
    //And add the new other half...
    vertices[i+1] = tri(v1.pt1, v1.pt2, ccpMidpoint(v1.pt1, v1.pt3));
    
    centerPt[i+1] = ccp((vertices[i+1].pt1.x + vertices[i+1].pt2.x + vertices[i+1].pt3.x)/3.0,
                        (vertices[i+1].pt1.y + vertices[i+1].pt2.y + vertices[i+1].pt3.y)/3.0);
    
    texCoords[i+1] = tri(t1.pt1, t1.pt2, ccpMidpoint(t1.pt1, t1.pt3));
    
    if (radial) {
        vdelta[i+1] = ccp(randf(originalVDelta.x, shatterSpeedVar/4.0), randf(originalVDelta.y, shatterSpeedVar/4.0));
        
    } else {
        vdelta[i+1] = ccp(randf(0.0, shatterSpeedVar), randf(0.0, shatterSpeedVar));
    }
    
    adelta[i+1] = randf(0.0, shatterRotVar);
    
    colorArray[i+1] = colorArray[i];
    
    //Copy for Shadows
    if (shadowed) {
        for (int j=0; j<numVertices; j++) {
            shadowVertices[j] = tri(ccpAdd(vertices[j].pt1, ccp(5, -5)), ccpAdd(vertices[j].pt2, ccp(5, -5)), ccpAdd(vertices[j].pt3, ccp(5, -5)));
        }
    }
}

void ShatteredSprite::shatterSprite(cocos2d::CCSprite *sprite, int piecesX, int piecesY, float speedVar, float rotVar, bool radialIn)
{
    //Do rendertexture to make a whole new texture, so not part of the textureCache
    CCRenderTexture *rt = CCRenderTexture::renderTextureWithWidthAndHeight(sprite->getContentSize().width, sprite->getContentSize().height);
    rt->begin();
    CCSprite *s2 = CCSprite::spriteWithTexture(sprite->getTexture(), sprite->getTextureRect());
    s2->setPosition(ccp(sprite->getContentSize().width/2, sprite->getContentSize().height/2));
    s2->visit();
    rt->end();
    
    //Uses the Sprite's texture to reuse things.
    setTexture(rt->getSprite()->getTexture());
    setTextureRect(CCRectMake(0, 0, sprite->getContentSize().width, sprite->getContentSize().height));
    
    //Sizey thingys
    float wid = sprite->getTexture()->getContentSizeInPixels().width;
    float hgt = sprite->getTexture()->getContentSizeInPixels().height;
    float    pieceXsize = (wid/(float)piecesX);//*CC_CONTENT_SCALE_FACTOR();
    float    pieceYsize = (hgt/(float)piecesY);//*CC_CONTENT_SCALE_FACTOR();
    
    //Texture is padded out to a power of 2!!
    float texWid = (wid/getTexture()->getPixelsWide());
    float texHgt = (hgt/getTexture()->getPixelsHigh());
    CCPoint centerPoint = ccp(wid/2, hgt/2);
    ccColor4B        color4 = {m_sColor.r, m_sColor.g, m_sColor.b, m_nOpacity };
    TriangleColors    triColor4 = { color4, color4, color4 };
    
    shatterSpeedVar = speedVar;
    shatterRotVar = rotVar;
    
    //Build the points first, so they can be wobbled a bit to look more random...
    //CCPoint    ptArray[piecesX+1][piecesY+1];
    CCPoint    ptArray[8+1][8+1];
    for (int x=0; x<=piecesX; x++) {
        for (int y=0; y<=piecesY; y++) {
            CCPoint            pt = CCPointMake((x*pieceXsize), (y*pieceYsize));
            //Edge pieces aren't wobbled, just interior.
            if (x>0 && x<piecesX && y>0 && y<piecesY) {
                pt = ccpAdd(pt, ccp(roundf(randf(0.0, pieceXsize*0.45)), roundf(randf(0.0, pieceYsize*0.45))));
            }
            ptArray[x][y] = pt;
            CCLog("px:%f, py:%f\n", pt.x, pt.y);
        }
    }
    
    numVertices = 0;
    for (int x=0; x<piecesX; x++) {
        for (int y=0; y<piecesY; y++) {
            if (numVertices>=SHATTER_VERTEX_MAX) {
                CCLog("NeedABiggerArray!");
                return;
            }
            
            //Direction (v) and rotation (a) are done by triangle too.
            //CenterPoint is for rotating each triangle
            //vdelta is random, but could be done based on distance/direction from the center of the image to explode out...
            if (slowExplosion) {
                vdelta[numVertices] = CCPointZero;
                adelta[numVertices] = 0.0;
            } else {
                vdelta[numVertices] = ccp(randf(0.0, speedVar), randf(0.0, speedVar));
                adelta[numVertices] = randf(0.0, rotVar);
            }
            colorArray[numVertices] = triColor4;
            
            if (slowExplosion) {
                vdelta[numVertices+1] = CCPointZero;
                adelta[numVertices+1] = 0.0;
            } else {
                vdelta[numVertices+1] = ccp(randf(0.0, speedVar), randf(0.0, speedVar));
                adelta[numVertices+1] = randf(0.0, rotVar);
            }
            colorArray[numVertices+1] = triColor4;
            
            //Randomly do the diagonal for the triangle
            if (rand()%2==0) {
                vertices[numVertices] = tri(ptArray[x][y],
                                            ptArray[x+1][y],
                                            ptArray[x][y+1]);
                centerPt[numVertices] = ccp((vertices[numVertices].pt1.x + vertices[numVertices].pt2.x + vertices[numVertices].pt3.x)/3.0,
                                            (vertices[numVertices].pt1.y + vertices[numVertices].pt2.y + vertices[numVertices].pt3.y)/3.0);
                texCoords[numVertices] = tri(ccp((ptArray[x][y].x/wid)*texWid, (ptArray[x][y].y/hgt)*texHgt),
                                             ccp((ptArray[x+1][y].x/wid)*texWid, (ptArray[x+1][y].y/hgt)*texHgt),
                                             ccp((ptArray[x][y+1].x/wid)*texWid, (ptArray[x][y+1].y/hgt)*texHgt));
                if (radialIn) {
                    vdelta[numVertices] = ccp((centerPt[numVertices].x - centerPoint.x)/(wid/2.0) * speedVar, (centerPt[numVertices].y - centerPoint.y)/(hgt/2.0) * speedVar);
                }
                numVertices++;
                
                //Triangle #2
                vertices[numVertices] = tri(ptArray[x+1][y],
                                            ptArray[x+1][y+1],
                                            ptArray[x][y+1]);
                centerPt[numVertices] = ccp((vertices[numVertices].pt1.x + vertices[numVertices].pt2.x + vertices[numVertices].pt3.x)/3.0,
                                            (vertices[numVertices].pt1.y + vertices[numVertices].pt2.y + vertices[numVertices].pt3.y)/3.0);
                texCoords[numVertices] = tri(ccp((ptArray[x+1][y].x/wid)*texWid, (ptArray[x+1][y].y/hgt)*texHgt),
                                             ccp((ptArray[x+1][y+1].x/wid)*texWid, (ptArray[x+1][y+1].y/hgt)*texHgt),
                                             ccp((ptArray[x][y+1].x/wid)*texWid, (ptArray[x][y+1].y/hgt)*texHgt));
                if (radialIn) {
                    vdelta[numVertices] = ccp((centerPt[numVertices].x - centerPoint.x)/(wid/2.0) * speedVar, (centerPt[numVertices].y - centerPoint.y)/(hgt/2.0) * speedVar);
                }
                numVertices++;
            } else {
                vertices[numVertices] = tri(ptArray[x][y],
                                            ptArray[x+1][y+1],
                                            ptArray[x][y+1]);
                centerPt[numVertices] = ccp((vertices[numVertices].pt1.x + vertices[numVertices].pt2.x + vertices[numVertices].pt3.x)/3.0,
                                            (vertices[numVertices].pt1.y + vertices[numVertices].pt2.y + vertices[numVertices].pt3.y)/3.0);
                texCoords[numVertices] = tri(ccp((ptArray[x][y].x/wid)*texWid, (ptArray[x][y].y/hgt)*texHgt),
                                             ccp((ptArray[x+1][y+1].x/wid)*texWid, (ptArray[x+1][y+1].y/hgt)*texHgt),
                                             ccp((ptArray[x][y+1].x/wid)*texWid, (ptArray[x][y+1].y/hgt)*texHgt));
                if (radialIn) {
                    vdelta[numVertices] = ccp((centerPt[numVertices].x - centerPoint.x)/(wid/2.0) * speedVar, (centerPt[numVertices].y - centerPoint.y)/(hgt/2.0) * speedVar);
                }
                numVertices++;
                
                //Triangle #2
                vertices[numVertices] = tri(ptArray[x][y],
                                            ptArray[x+1][y],
                                            ptArray[x+1][y+1]);
                centerPt[numVertices] = ccp((vertices[numVertices].pt1.x + vertices[numVertices].pt2.x + vertices[numVertices].pt3.x)/3.0,
                                            (vertices[numVertices].pt1.y + vertices[numVertices].pt2.y + vertices[numVertices].pt3.y)/3.0);
                texCoords[numVertices] = tri(ccp((ptArray[x][y].x/wid)*texWid, (ptArray[x][y].y/hgt)*texHgt),
                                             ccp((ptArray[x+1][y].x/wid)*texWid, (ptArray[x+1][y].y/hgt)*texHgt),
                                             ccp((ptArray[x+1][y+1].x/wid)*texWid, (ptArray[x+1][y+1].y/hgt)*texHgt));
                if (radialIn) {
                    vdelta[numVertices] = ccp((centerPt[numVertices].x - centerPoint.x)/(wid/2.0) * speedVar, (centerPt[numVertices].y - centerPoint.y)/(hgt/2.0) * speedVar);
                }
                numVertices++;
            }
        }
    }
    
    //Copy for Shadows
    for (int j=0; j<numVertices; j++) {
        shadowVertices[j] = tri(ccpAdd(vertices[j].pt1, ccp(5, -5)), ccpAdd(vertices[j].pt2, ccp(5, -5)), ccpAdd(vertices[j].pt3, ccp(5, -5)));
    }
}