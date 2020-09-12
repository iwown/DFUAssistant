//
//  rc4_mtk.h
//  MyTest
//
//  Created by user on 11/5/14.
//  Copyright (c) 2014 __mediatek__. All rights reserved.
//

#ifndef __MyTest__rc4_mtk__
#define __MyTest__rc4_mtk__

#include <stdio.h>


#define  S_SWAP(sa, sb) do { unsigned char t = sa; sa = sb; sb =t; } while(0)

typedef struct RC4_CNXT_T {
    unsigned char x, y;
    unsigned char keyStream[256];

} RC4_CNXT;

void che_rc4_process(RC4_CNXT *keySet, int data_len, unsigned char *data, unsigned char *output);
void che_rc4_set_key(RC4_CNXT *keySet, int len, unsigned char *data);

#endif /* defined(__MyTest__rc4_mtk__) */
