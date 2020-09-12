//
//  Command.h
//  MyTest
//
//  Created by user on 11/5/14.
//  Copyright (c) 2014 __mediatek__. All rights reserved.
//

#ifndef __MyTest__Command__
#define __MyTest__Command__

#include <stdio.h>
#include <stdlib.h>

unsigned char* SPC_getDatacmd(int cmd, unsigned char *args, int *retLen) ;
int SPC_getCmdType(unsigned char *command, int commandLength);
int SPC_getDataLength(unsigned char *command, int commandLength);
int SPC_setKey(unsigned char *keyChars, int length);



#endif /* defined(__MyTest__Command__) */
