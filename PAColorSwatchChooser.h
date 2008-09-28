//
//  PAColorSwatchChooser.h
//  Papaya
//
//  Created by Tomas Franzén on 2008-06-02.
//  Copyright 2008 Lighthead Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PAColorSwatchChooserDelegate
- (NSString*)labelNameForIndex:(int)index;
@end

@interface PAColorSwatchChooser : NSView {
	int selectedIndex;
	BOOL enabled;
	int highlightedIndex;
	NSTrackingRectTag tags[8];

	id<NSObject,PAColorSwatchChooserDelegate> delegate;
	BOOL drawLabels;
	id target;
	SEL action;
}
@property (assign) id delegate;
@property (assign) BOOL enabled;
@property (assign) id target;
@property (assign) SEL action;
@property (readonly) int selectedIndex;
@end
