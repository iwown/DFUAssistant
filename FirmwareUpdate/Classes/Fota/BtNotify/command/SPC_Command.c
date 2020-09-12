//
//  Command.c
//  MyTest
//
//  Created by user on 11/5/14.
//  Copyright (c) 2014 __mediatek__. All rights reserved.
//

#include "SPC_Command.h"
#include <string.h>
//#include "rc4_mtk.h"

#if __cpluscplus
extern "C" {
#endif

#define  KEY_LENGTH 130
#define  LENGTH_OF_HEAD 8

typedef enum {
    NOTREC = 0,
    DATA = 1,
    SYNC = 2,
    ACKY = 3,
    VERN = 4,
    MAPX = 5,
    MAPD = 6,
    CAPC = 7,
    MREE = 8,
    EXCD = 9
} CMDENUM;

unsigned char key[KEY_LENGTH] = "we had everything before us, we had nothing before us, we were all going direct to Heaven, we were all going direct the other way";

//RC4_CNXT rc4_key_mtk;

unsigned char* getTheDataBuffer(char *command, int *p);

unsigned char* SPC_getDatacmd(int cmd, unsigned char *args, int *retLen) {
    char *command = NULL;
    
    switch (cmd) {
        case DATA:
            asprintf(&command, "DATA %s", args);
            break;
        
        case SYNC:
            asprintf(&command, "SYNC %s", args);
            break;
        
        case MAPX:
            asprintf(&command, "MAPX %s", args);
            break;
            
        case MAPD:
            asprintf(&command, "MAPD %s", args);
            break;
            
        case CAPC:
            asprintf(&command, "CAPC %s", args);
            break;
            
        case MREE:
            asprintf(&command, "MREE %s", args);
            break;
            
        case EXCD:
            asprintf(&command, "EXCD %s", args);
            break;
            
        default:
            break;
    }
    
    int resultLen = 0;
    int *pResultLen = &resultLen;
    
    unsigned char *cipherbytes = getTheDataBuffer(command, pResultLen);
    
    if (cipherbytes == NULL) {
        printf("[BLE][Command]SPC_getDatacmd::cipherbytes == null\n");
    }
    *retLen = resultLen;
    return cipherbytes;
}

int SPC_getCmdType(unsigned char *command, int commandLength) {
    int result = -1;
    //int lenOfkey = KEY_LENGTH;
    //che_rc4_set_key(&rc4_key_mtk, lenOfkey, &key[0]);
    
    unsigned char *ciphertext = (unsigned char*) malloc(sizeof( unsigned char)*commandLength);
    //che_rc4_process(&rc4_key_mtk, commandLength, commandChars, ciphertext);
    memset(ciphertext, 0, commandLength);
    memcpy(ciphertext, command, commandLength);
    
    if((ciphertext[0] == 'D') && (ciphertext[1] == 'A') && (ciphertext[2] == 'T') && (ciphertext[3] == 'A'))
    {
        result = DATA;
    }
    else if ((ciphertext[0] == 'S') && (ciphertext[1] == 'Y') && (ciphertext[2] == 'N') && (ciphertext[3] == 'C'))
    {
        result =  SYNC;
    }
    else if ((ciphertext[0] == 'A') && (ciphertext[1] == 'C') && (ciphertext[2] == 'K') && (ciphertext[3] == 'Y'))
    {
        result =  ACKY;
    }
    else if ((ciphertext[0] == 'V') && (ciphertext[1] == 'E') && (ciphertext[2] == 'R') && (ciphertext[3] == 'N'))
    {
        result =  VERN;
    }
    else if ((ciphertext[0] == 'M') && (ciphertext[1] == 'A') && (ciphertext[2] == 'P') && (ciphertext[3] == 'X'))
    {
        result =  MAPX;
    }
    else if ((ciphertext[0] == 'M') && (ciphertext[1] == 'A') && (ciphertext[2] == 'P') && (ciphertext[3] == 'D'))
    {
        result =  MAPD;
    }
    else if ((ciphertext[0] == 'C') && (ciphertext[1] == 'A') && (ciphertext[2] == 'P') && (ciphertext[3] == 'C'))
    {
        result =  CAPC;
    }
    else if ((ciphertext[0] == 'M') && (ciphertext[1] == 'R') && (ciphertext[2] == 'E') && (ciphertext[3] == 'E'))
    {
        result =  MREE;
    }
    else if ((ciphertext[0] == 'E') && (ciphertext[1] == 'X') && (ciphertext[2] == 'C') && (ciphertext[3] == 'D'))
    {
        result =  EXCD;
    }
    //free(commandChars);
    free(ciphertext);
    
    return result;
}

int SPC_getDataLength(unsigned char *command, int commandLength) {
    
    int result = -1;

    //int lengthOfKey = KEY_LENGTH;
    //che_rc4_set_key( &rc4_key_mtk, lengthOfKey, &key[0]);
    
    unsigned char *ciphertext = (unsigned char *)malloc(commandLength);
    //che_rc4_process(&rc4_key_mtk, commandLength, commandChars, ciphertext);
    memset(ciphertext, 0, commandLength);
    memcpy(ciphertext, command, commandLength);
    
    if((ciphertext[0] == 'D') && (ciphertext[1] == 'A') && (ciphertext[2] == 'T') && (ciphertext[3] == 'A'))
    {
        result = atoi((const char*)&(ciphertext[5]));
    }
    if((ciphertext[0] == 'V') && (ciphertext[1] == 'E') && (ciphertext[2] == 'R') && (ciphertext[3] == 'N'))
    {
        result = atoi((const char*)&(ciphertext[5]));
    }
    if((ciphertext[0] == 'M') && (ciphertext[1] == 'A') && (ciphertext[2] == 'P') && (ciphertext[3] == 'X'))
    {
        result = atoi((const char*)&(ciphertext[5]));
    }
    if((ciphertext[0] == 'M') && (ciphertext[1] == 'A') && (ciphertext[2] == 'P') && (ciphertext[3] == 'D'))
    {
        result = atoi((const char*)&(ciphertext[5]));
    }
    if((ciphertext[0] == 'C') && (ciphertext[1] == 'A') && (ciphertext[2] == 'P') && (ciphertext[3] == 'C'))
    {
        result = atoi((const char*)&(ciphertext[5]));
    }
    if((ciphertext[0] == 'M') && (ciphertext[1] == 'R') && (ciphertext[2] == 'E') && (ciphertext[3] == 'E'))
    {
        result = atoi((const char*)&(ciphertext[5]));
    }
    if((ciphertext[0] == 'E') && (ciphertext[1] == 'X') && (ciphertext[2] == 'C') && (ciphertext[3] == 'D'))
    {
        result = atoi((const char*)&(ciphertext[5]));
    }
    if((ciphertext[0] == 'A') && (ciphertext[1] == 'C') && (ciphertext[2] == 'K') && (ciphertext[3] == 'Y'))
    {
        result = atoi((const char*)&(ciphertext[5]));
    }
    free(ciphertext);
    //free(commandChars);
    return result;
    
}

int SPC_setKey(unsigned char *keyChars, int length) {
    for (int i = 0; i < length; i ++) {
        *(key + i) = *(keyChars + i);
    }
    
    return 0;
}

unsigned char* getTheDataBuffer(char *command, int *p) {
    //int lenthOfKey = KEY_LENGTH;
    //che_rc4_set_key(&rc4_key_mtk, lenthOfKey, &key[0]);
    int lenthOfCommand = (int)strlen(command) + 1;
    
    unsigned char *ciphertext;
    ciphertext = (unsigned char *)malloc(lenthOfCommand);
    //che_rc4_process(&rc4_key_mtk, lenthOfCommand, (unsigned char*)command, ciphertext);
    memcpy(ciphertext, command, lenthOfCommand);
    
    unsigned char *cipherbytes;
    cipherbytes = (unsigned char *)malloc(lenthOfCommand + 8);
    
    cipherbytes[0] = 0xF0;
    cipherbytes[1] = 0xF0;
    cipherbytes[2] = 0xF0;
    cipherbytes[3] = 0xF1;
    cipherbytes[4] = (unsigned char)((0xFF000000 & lenthOfCommand) >> 24);
    cipherbytes[5] = (unsigned char)((0x00FF0000 & lenthOfCommand) >> 16);
    cipherbytes[6] = (unsigned char)((0x0000FF00 & lenthOfCommand) >> 8);
    cipherbytes[7] = (unsigned char)(0x000000FF & lenthOfCommand);
    
    int i = LENGTH_OF_HEAD;
    for( i = LENGTH_OF_HEAD; i < lenthOfCommand + LENGTH_OF_HEAD; i ++)
    {
        cipherbytes[i] = ciphertext[i - LENGTH_OF_HEAD];
    }

    *p = (lenthOfCommand + 8);
    return cipherbytes;
}
    
#if __cplusplus
}
#endif
