//
//  LEPIMAPFetchAllFoldersRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 18/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPIMAPFetchFoldersRequest.h"

@interface LEPIMAPFetchAllFoldersRequest : LEPIMAPFetchFoldersRequest {
    BOOL _useXList;
}

@property (nonatomic, assign) BOOL useXList;

@end
