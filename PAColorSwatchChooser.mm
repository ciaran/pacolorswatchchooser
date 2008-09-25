//
//  PAColorSwatchChooser.m
//  Papaya
//
//  Created by Tomas Franzén on 2008-06-02.
//  Copyright 2008 Lighthead Software. All rights reserved.
//

#import "PAColorSwatchChooser.h"

static const float SwatchDiameter  = 9;
static const float SwatchMargin    = 4;
static const float LabelNameHeight = 15;

@implementation PAColorSwatchChooser

- (id)initWithFrame:(NSRect)rect
{
	if(self = [super initWithFrame:rect]) {
		enabled          = YES;
		highlightedIndex = -1;
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
	return (index < 8) ? NSMakeRect(5 + index*(SwatchDiameter + SwatchMargin*2), (drawLabels ? LabelNameHeight : 0) + 5, SwatchDiameter, SwatchDiameter) : NSZeroRect;
}


- (void)mouseDown:(NSEvent *)theEvent {
	if(!enabled) return;
	NSPoint localPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	for(int i=0;i<8;i++) {
		NSRect hitRect = NSInsetRect([self rectForSwatchAtIndex:i], -(SwatchMargin+1), -(SwatchMargin+1));
		if(NSPointInRect(localPoint, hitRect))
			selectedIndex = i;
	}
	[self updateModel];
	[self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)rect {
	struct swatch_t {
		struct color_t {
			CGFloat red, green, blue;

			NSColor *color(float alpha) {
				return [NSColor colorWithDeviceRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
			}
		};
		NSColor *from(float alpha)	{ return _from.color(alpha);	}
		NSColor *to(float alpha)	{ return _to.color(alpha);		}

		color_t _from, _to;
	} swatches[] = {
		{{0,0,0},{0,0,0}},					{{252,162,154},{251,100,91}},
		{{249,206,143},{246,170,68}},		{{249,242,151},{239,219,71}},
		{{212,233,151},{180,214,71}},		{{167,208,255},{90,162,255}},
		{{224,190,234},{192,142,217}},	{{205,205,206},{169,169,169}},
	};
	
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowColor:[NSColor colorWithDeviceWhite:0 alpha:0.75]];
	[shadow setShadowOffset:NSMakeSize(0,-1)];
	[shadow setShadowBlurRadius:2];
	[shadow set];
	
	NSShadow *noShadow = [[[NSShadow alloc] init] autorelease];
	
	int i;
	for(i=0;i<8;i++) {
		NSRect swatchRect = [self rectForSwatchAtIndex:i];
		
		float alpha = 1.0; //enabled ? 1.0 : 0.6;
		
		NSColor *fc = swatches[i].from(alpha);
		NSColor *tc = swatches[i].to(alpha);
		
		if((i == highlightedIndex || i == selectedIndex) && enabled) {
			NSRect outerRect = NSInsetRect(swatchRect,-SwatchMargin,-SwatchMargin);
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
			
			NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:swatches[i].from(alpha) endingColor:tc];
			[gradient drawInRect:swatchRect angle:-90];
			[gradient release];
			
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
	[noShadow set];

	if(highlightedIndex != -1) {
		NSFont *font   = [[NSFontManager sharedFontManager] convertFont:[NSFont menuFontOfSize:12] toHaveTrait:NSBoldFontMask];
		if(drawLabels) {
			NSString *name                 = [delegate labelNameForIndex:highlightedIndex];
			NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
			[style setAlignment:NSCenterTextAlignment];
			NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,
																										 [NSColor grayColor], NSForegroundColorAttributeName,
																										 style, NSParagraphStyleAttributeName,
																										 nil];
			[style release];
			[[NSString stringWithFormat:@"“%@”", name] drawInRect:NSMakeRect(0, 0, [self bounds].size.width, 15) withAttributes:attributes];
		}
	}
}

- (void)setupTrackingRects {
	int i;
	for(i=0;i<8;i++) {
		if(tags[i])
			[self removeTrackingRect:tags[i]];
		tags[i] = [self addTrackingRect:NSInsetRect([self rectForSwatchAtIndex:i], -SwatchMargin, -SwatchMargin) owner:self userData:(void*)i assumeInside:NO];
	}
}

- (void)mouseEntered:(NSEvent*)event {
	[super mouseEntered:event];
	highlightedIndex = (int)[event userData];
	[self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent*)event {
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

@synthesize enabled, delegate;

- (void)setDelegate:(id)newDelegate {
	delegate   = newDelegate;
	drawLabels = delegate && [delegate respondsToSelector:@selector(labelNameForIndex:)];
	[self setupTrackingRects];
}
@end
