//
//  CCLocalizedString.cpp
//  SkeletonX
//
//  Created by mac on 11-12-1.
//  Copyright (c) 2011年 GeekStudio. All rights reserved.
//


#include "CCApplication.h"
#include "CCCommon.h"
#include "CCFileUtils.h"
#include "CCDirector.h"
#include "CCString.h"
USING_NS_CC;

#include <iostream>
#include <sstream>
#include <string>
#include <map>
using namespace std;

#include "CCLocalizedString.h"

static map<string,string> localizedStrings;

const char * CCLocalizedString(const char * mKey,const char * fileName)
{
    ccLanguageType curLanguage = CCApplication::sharedApplication()->getCurrentLanguage();
    const char * language;
    switch (curLanguage)
    {
        default:
        case kLanguageEnglish:
            language = "_en";
            break;
        case kLanguageChinese:
            language = "_zh";
            break;
    }
    string localizedFileName = string(fileName) + string(language);

    string resultStr;
    
    if (localizedStrings.empty()) 
    {
        // Initialize variables needed
        unsigned long fileSize = 0;
        unsigned char * fileContents = NULL;
        string line, fullPath, contents;
        
        // Get absolute path of file
        fullPath = CCFileUtils::sharedFileUtils()->fullPathForFilename(localizedFileName.c_str());
        
        // Get data of file
        fileContents = CCFileUtils::sharedFileUtils()->getFileData( fullPath.c_str( ) , "r", &fileSize );
        contents.append( ( char * ) fileContents );
        
        // Create a string stream so that we can use getline( ) on it
        istringstream fileStringStream( contents );
        
        // Get file contents line by line
        while ( std::getline( fileStringStream, line ) )
		{
//            debug_Printf("line :%s",line.c_str());
            if (line.find("/*",0) == string::npos &&
                line.find("//",0) == string::npos &&
                line.find("*/",0) == string::npos ) //filter the valid string of one line
            {
//                debug_Printf("find the line not start with \" /* \"");
                string::size_type validPos= line.find('=',0);
                if ( validPos != string::npos) 
                {
//                    debug_Printf("fimd the line contain \" = \"");
                    string keyStr = line.substr(0,validPos-1);
                    string subStr = line.substr(validPos+1,line.size()-1); // get valid string
 
                    //trim space
                    keyStr.erase(0, keyStr.find_first_not_of(" \t")); // 去掉头部空格
                    keyStr.erase(keyStr.find_last_not_of(" \t") + 1); // 去掉尾部空格
                    
                    subStr.erase(0, subStr.find_first_not_of(" \t")); // 去掉头部空格
                    subStr.erase(subStr.find_last_not_of(" \t") + 1); // 去掉尾部空格
                    
                    //trim \" 
                    keyStr.erase(0, keyStr.find_first_not_of("\""));
                    keyStr.erase(keyStr.find_last_not_of("\"") + 1);
                    
                    subStr.erase(0, subStr.find_first_not_of("\""));
                    
                    
                    //trim ; character and last \" character
                    subStr.erase(subStr.find_last_not_of(";") + 1);
                    subStr.erase(subStr.find_last_not_of("\"") + 1);
                    
                    
                    //replace line feed with \n
                    string::size_type pos(0);
                    string old_value("\\n");
                    if((pos=subStr.find(old_value))!=string::npos)
                    {
                        for(; pos!=string::npos; pos+=1)
                        {   
                            if((pos=subStr.find(old_value,pos))!=string::npos)
                            {
                                subStr.erase(pos, 2);
                                subStr.insert(pos, 1, '\n');
                            }   
                            else   
                                break;
                        }
                    }
                    
                    localizedStrings.insert(std::pair<string, string>(keyStr,subStr));
                    
                    const char * keyChars = keyStr.c_str();
                    
                    if (strcmp(keyChars,mKey) == 0) {
                        resultStr = subStr;
                    }
                }
            }
        }
        //must delete fileContents
        if (fileContents!= NULL) {
            delete [] fileContents;
            fileContents = NULL;
        }
        
        //return valid value
        if (resultStr.length() > 0){
            return (string(resultStr)).c_str();
        }
        return mKey;
    }
    else
    {
        std::map<string,string>::iterator itr = localizedStrings.find(string(mKey));
        if (itr != localizedStrings.end()) {
            return (itr->second).c_str();
        }
    }
    return mKey;
}

const char * CCLocalizedString(const char * mKey)
{
    return CCLocalizedString(mKey, "Localizable");
}
