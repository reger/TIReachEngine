//
//  TIReachEngineConnection.h
//  TIReachEngine
//
//  Created by Tom Irving on 20/09/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "TIReachEngineGlobal.h"

typedef enum {
	TIReachEngineConnectionTypeGameMetadata = 0,
	TIReachEngineConnectionTypeGameHistory,
	TIReachEngineConnectionTypeGameDetails,
	TIReachEngineConnectionTypePlayerDetails,
	TIReachEngineConnectionTypePlayerFileShare,
	TIReachEngineConnectionTypeFileDetails,
	TIReachEngineConnectionTypePlayerFileSets,
	TIReachEngineConnectionTypePlayerFileSetFiles,
	TIReachEngineConnectionTypePlayerScreenshots,
	TIReachEngineConnectionTypePlayerRenderedVideos,
	TIReachEngineConnectionTypeFileSearch,
	TIReachEngineConnectionTypeChallenges,
} TIReachEngineConnectionType;

@interface TIReachEngineConnection : NSURLConnection {
	
	TIReachEngineConnectionType connectionType;
	NSDictionary * userInfo;

}

@property (nonatomic, assign) TIReachEngineConnectionType connectionType;
@property (nonatomic, retain) NSDictionary * userInfo;

@end
