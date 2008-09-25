//
//  PAColorSwatchChooser.m
//  Papaya
//
//  Created by Tomas Franzén on 2008-06-02.
//  Copyright 2008 Lighthead Software. All rights reserved.
//

#import "PAColorSwatchChooser.h"


@implementation PAColorSwatchChooser

- (id)initWithFrame:(NSRect)rect
{
	if(self = [super initWithFrame:rect]) {
		enabled = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDidChange:) name:NSViewFrameDidChangeNotification object:self];
	}
	return self;
}

+ (void)initialize {
	[self exposeBinding:@"selectedIndex"];
	[self exposeBinding:@"isEnabled"];
}

- (void)setSelectedIndex:(int)index {
	if(index == selectedIndex) return;
	selectedIndex = index;
	[self setNeedsDisplay:YES];
}

- (int)selectedIndex {
	return selectedIndex;
}

- (void)updateModel {
	NSDictionary *binding = [self infoForBinding:@"selectedIndex"];
	id controller = [binding objectForKey:NSObservedObjectKey];
	NSString *keyPath = [binding objectForKey:NSObservedKeyPathKey];
	[controller setValue:[NSNumber numberWithInt:selectedIndex] forKeyPath:keyPath];
}

- (NSRect)rectForSwatchAtIndex:(int)index {
	return (index < 8) ? NSMakeRect(5 + index*20,5,10,10) : NSZeroRect;
}


- (void)mouseDown:(NSEvent *)theEvent {
	if(!enabled) return;
	NSPoint localPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	for(int i=0;i<8;i++) {
		NSRect hitRect = NSInsetRect([self rectForSwatchAtIndex:i], -4, -4);
		if(NSPointInRect(localPoint, hitRect))
			selectedIndex = i;
	}
	[self updateModel];
	[self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)rect {
	CGFloat rc[] = {0,0,252.0f,251.0f,249.0f,246.0f,249.0f,239.0f,212.0f,180.0f,167.0f,90.0f,224.0f,192.0f,205.0f,169.0f};
	CGFloat gc[] = {0,0,162.0f,100.0f,206.0f,170.0f,242.0f,219.0f,233.0f,214.0f,208.0f,162.0f,190.0f,142.0f,205.0f,169.0f};
	CGFloat bc[] = {0,0,154.0f,91.0f,143.0f,68.0f,151.0f,71.0f,151.0f,71.0f,255.0f,255.0f,234.0f,217.0f,206.0f,169.0f};
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:[NSColor colorWithDeviceWhite:0 alpha:0.75]];
	[shadow setShadowOffset:NSMakeSize(0,-1)];
	[shadow setShadowBlurRadius:2];
	[shadow set];
	
	NSShadow *noShadow = [[NSShadow alloc] init];
	
	int i;
	for(i=0;i<8;i++) {
		NSRect swatchRect = [self rectForSwatchAtIndex:i];
		
		float alpha = 1.0; //enabled ? 1.0 : 0.6;
		
		NSColor *fc = [NSColor colorWithDeviceRed:rc[i*2]/255.0f green:gc[i*2]/255.0f blue:bc[i*2]/255.0f alpha:alpha];
		NSColor *tc = [NSColor colorWithDeviceRed:rc[(i*2)+1]/255.0f green:gc[(i*2)+1]/255.0f blue:bc[(i*2)+1]/255.0f alpha:alpha];
		
		if((i == highlightedIndex || i == selectedIndex) && enabled) {
			NSRect outerRect = NSInsetRect(swatchRect,-3,-3);
			NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:outerRect xRadius:2 yRadius:2];
			[noShadow set];
			if(i == highlightedIndex) {
				[[NSColor colorWithDeviceWhite:0.8 alpha:1] set];
				[path fill];
			}
			[[NSColor colorWithDeviceWhite:0.6 alpha:1] set];
			[path stroke];
		}
		
		if(i > 0) {
			[shadow set];
			[[NSColor whiteColor] set];
			[[NSBezierPath bezierPathWithRect:swatchRect] fill];
			
			if(!enabled) {
				fc = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
				tc = [NSColor colorWithDeviceWhite:0.70 alpha:1.0];
			}
			
			[[[NSGradient alloc] initWithStartingColor:fc endingColor:tc] drawInRect:swatchRect angle:-90];
			
		}else{
			[noShadow set];
			if(enabled)
				[[NSColor colorWithDeviceWhite:0.4 alpha:1] set];
			else
				[[NSColor colorWithDeviceWhite:0.7 alpha:1] set];
			
			swatchRect = NSInsetRect(swatchRect, 1.5, 1.5);
			
			NSBezierPath *line = [NSBezierPath bezierPath];
			[line moveToPoint:swatchRect.origin];
			[line lineToPoint:NSMakePoint(swatchRect.origin.x+swatchRect.size.width, swatchRect.origin.y+swatchRect.size.height)];
			[line setLineWidth:2];
			[line stroke];
			
			line = [NSBezierPath bezierPath];
			[line moveToPoint:NSMakePoint(swatchRect.origin.x+swatchRect.size.width, swatchRect.origin.y)];
			[line lineToPoint:NSMakePoint(swatchRect.origin.x, swatchRect.origin.y+swatchRect.size.height)];
			[line setLineWidth:2];
			[line stroke];
		}
	}
}

- (void)setupTrackingRects
{
	int i;
	for(i=0;i<8;i++) {
		if(tags[i])
			[self removeTrackingRect:tags[i]];
		tags[i] = [self addTrackingRect:NSInsetRect([self rectForSwatchAtIndex:i], -3, -3) owner:self userData:i assumeInside:NO];
	}
}

- (void)mouseEntered:(NSEvent*)event
{
	[super mouseEntered:event];
	highlightedIndex = [event userData];
	[self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent*)event
{
	[super mouseExited:event];
	highlightedIndex = -1;
	[self setNeedsDisplay:YES];
}

- (void)viewDidMoveToWindow {
	[super viewDidMoveToWindow];
	[self setupTrackingRects];
}

- (void)frameDidChange:(NSNotification*)notification {
	[self setupTrackingRects];
}

- (BOOL)isEnabled {
	return enabled;
}

- (void)setIsEnabled:(BOOL)enable {
	enabled = enable;
}

@end
