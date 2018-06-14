//
//  SUOTAServiceManager.h
//  SmartTags
//
//  Created by Martijn Houtman on 03/10/14.
//  Copyright (c) 2014 Martijn Houtman. All rights reserved.
//

#import "GenericServiceManager.h"

extern NSString * const SUOTAServiceNotFound;

@interface SUOTAServiceManager : GenericServiceManager

@property BOOL suotaReady;

@end
