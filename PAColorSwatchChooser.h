//
//  PAColorSwatchChooser.h
//  Papaya
//
//  Created by Tomas Franzén on 2008-06-02.
//  Copyright 2008 Lighthead Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PAColorSwatchChooser : NSView {
	int selectedIndex;
	BOOL enabled;
	int highlightedIndex;
	NSTrackingRectTag tags[8];
}

@end
