//
//  rc4_mtk.c
//  MyTest
//
//  Created by user on 11/5/14.
//  Copyright (c) 2014 __mediatek__. All rights reserved.
//

#include "rc4_mtk.h"
#include <stdlib.h>

void che_rc4_process(RC4_CNXT *keySet, int data_len, unsigned char *data, unsigned char *output) {
#if 0
    int x, y, k;
    unsigned char* s = keySet->keyStream;
    
    x = keySet->x;
    y = keySet->y;
    
    for (k = 0; k < data_len; k++)
    {
        x = (x + 1) & 0xff;
        y = (y + s[x]) & 0xff;
        S_SWAP(s[x], s[y]);
        *output = (*data) ^ (s[(s[x] + s[y]) & 0xff]);
        output++;
        data++;
    }
    
    keySet->x = x;
    keySet->y = y;
#endif
    
    int k = 0;
    for (k = 0; k < data_len; k++) {
        *output = (*data);
        output ++;
        data ++;
    }
}

void che_rc4_set_key(RC4_CNXT *keySet, int len, unsigned char *data) {
#if 0
    int i, j, k;
    unsigned char* s = keySet->keyStream;
    
    /* Setup RC4 state */
    for (k = 0; k < 256; k++) {
        s[k] = k;
    }
    
    j=0;
    k = 0;
    for (i = 0; i < 256; i++)
    {
        j = (j + s[i] + data[k]) & 0xff;
        if (++k == len)
            k = 0;
        S_SWAP(s[i], s[j]);
    }
    keySet->x = 0;
    keySet->y= 0;
#endif
}
