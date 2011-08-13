//
//  EFView.m
// EFLaceView
//
//  Created by MacBook Pro ef on 25/07/06.
//  Copyright 2006 Edouard FISCHER. All rights reserved.
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//	-	Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//	-	Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//	-	Neither the name of Edouard FISCHER nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "EFView.h"
#import "EFLaceView.h"
#import "Utils.h"


static void *_inoutputObservationContext = (void *)1094;

@implementation EFView

#pragma mark -
#pragma mark *** init routines ***
- (id) init {
	return [self initWithFrame:NSMakeRect(0,0,10,10)];
}

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
    if (self) {
		_inputs = [[NSMutableSet alloc] init];
		_outputs = [[NSMutableSet alloc] init];
		
		_stringAttributes = [[NSMutableDictionary alloc] init];
		[_stringAttributes setObject:[NSFont messageFontOfSize:10] forKey:NSFontAttributeName];
		[_stringAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
		
		_title = @"Title bar";
		NSSize titleSize = [[self title] sizeWithAttributes:_stringAttributes];
		_titleColor = [NSColor greenColor];

		_verticalOffset = titleSize.height/2;
		
		[self setFrameSize:[self minimalSize]];
		[self setNeedsDisplay:YES];
		
		// need to update view when labels or positions are changed in inputs or ouputs
		[self addObserver:self forKeyPath:@"inputs" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:_inoutputObservationContext];
		[self addObserver:self forKeyPath:@"outputs" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:_inoutputObservationContext];
	}
    return self;
}

- (void)removeFromSuperview {
	for (id anObject in _inputs) {
		[anObject removeObserver:self forKeyPath:@"label"];
		[anObject removeObserver:self forKeyPath:@"position"];
	}
	for (id anObject in _outputs) {
		[anObject removeObserver:self forKeyPath:@"label"];
		[anObject removeObserver:self forKeyPath:@"position"];
	}
	[super removeFromSuperview];
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"inputs"];
	[self removeObserver:self forKeyPath:@"outputs"];
}


#pragma mark -
#pragma mark *** setters and accessors ***
//vertical Offset
- (float)verticalOffset {
	return _verticalOffset;
}

- (void)setVerticalOffset:(float)aValue {
	_verticalOffset = MAX(aValue,0);	
	[self setHeight:MAX([self minimalSize].height,[self height])];
	[[self superview] setNeedsDisplay:YES];
}

- (BOOL)isSelected{
	return [[(EFLaceView*)[self superview] selectedSubViews] containsObject:self];
}

// title color
- (NSColor *)titleColor {
	return _titleColor;
}

- (void)setTitleColor:(NSColor *)aColor {
	if (aColor != [self titleColor]) {
		_titleColor = aColor;
	}
	[self setNeedsDisplay:YES];
}

// title
- (NSString *)title {
	return (_title == nil)?@"":_title;
}

- (void)setTitle:(NSString *)aTitle {
	if (aTitle != _title) {
		_title = aTitle;
		[self setWidth:MAX([self minimalSize].width,[self width])];
		[self setNeedsDisplay:YES];
	}
}

- (float) originX {
	return [self frame].origin.x;
}

- (float) originY {
	return [self frame].origin.y;
}

- (float) width {
	return [self frame].size.width;
}

- (float) height {
	return [self frame].size.height;
}

-(void) setOriginX:(float)aFloat {
	if (aFloat != [self originX]) {
		NSRect frame = [self frame];
		frame.origin.x = aFloat;
		[self setFrame:frame];
		[[self superview] setNeedsDisplay:YES];
	}
}

-(void) setOriginY:(float)aFloat {
	if (aFloat != [self originY]) {
		NSRect frame = [self frame];
		frame.origin.y = aFloat;
		[self setFrame:frame];
		[[self superview] setNeedsDisplay:YES];
	}
}

-(void) setWidth:(float)aFloat {
	if (aFloat != [self width]) {
		NSRect frame = [self frame];
		frame.size.width = MAX(aFloat,[self minimalSize].width);
		[self setFrame:frame];
		[[self superview] setNeedsDisplay:YES];
	}
}

-(void) setHeight:(float)aFloat {
	if (aFloat != [self height]) {
		NSRect frame = [self frame];
		frame.size.height = MAX(aFloat,[self minimalSize].height);
		[self setFrame:frame];
		[[self superview] setNeedsDisplay:YES];
	}
}


#pragma mark inputs

- (NSMutableSet *)inputs {
    return _inputs; 
}

- (void)setInputs:(NSMutableSet *)aSet {
	if (aSet != _inputs) {
		_inputs = aSet;
	}
}

- (NSArray *)orderedInputs {
	return [self orderedHoles:[self inputs]];
}

- (NSArray *)orderedHoles:(NSSet *)aSet {
	NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
	NSArray* result = [[aSet allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
	return result;
}

#pragma mark outputs
- (NSMutableSet *)outputs {
	return _outputs; 
}

- (void)setOutputs:(NSMutableSet *)aSet {
	if (aSet != _outputs) {
		_outputs = aSet;
	}
}

- (NSArray *)orderedOutputs {
	return [self orderedHoles:[self outputs]];
}

#pragma mark -
#pragma mark *** geometry ***

- (id) endHole:(NSPoint)aPoint {
	NSPoint mousePos = [self convertPoint:aPoint fromView:[self superview]];
	NSSize stringSize = [[self title] sizeWithAttributes:_stringAttributes];
	float heightOfText = stringSize.height;
	if ((mousePos.x>0) && (mousePos.x <15)) {
		int hole = (-mousePos.y + [self bounds].origin.y + [self bounds].size.height - [self verticalOffset] - heightOfText*0.5 ) / heightOfText;
		id res = ((hole >0)&&(hole <=[[self inputs] count]))?[[self orderedInputs] objectAtIndex:hole-1]:nil;
		if (res) {
			[res setValue:_data forKey:@"data"];
		}
		return res;
	}
	return nil;
}

- (id) startHole:(NSPoint)aPoint {
	NSPoint mousePos = [self convertPoint:aPoint fromView:[self superview]];
	NSSize stringSize = [[self title] sizeWithAttributes:_stringAttributes];
	float heightOfText = stringSize.height;
	if ((mousePos.x>[self bounds].origin.x+[self bounds].size.width-15) && (mousePos.x <[self bounds].origin.x+[self bounds].size.width)) {
		int hole = (-mousePos.y + [self bounds].origin.y + [self bounds].size.height - [self verticalOffset] - heightOfText*0.5) / heightOfText;
		id res = ((hole >0)&&(hole <=[[self outputs] count]))?[[self orderedOutputs] objectAtIndex:hole-1]:nil;
		if (res) {
			[res setValue:_data forKey:@"data"];
		}
		return res;
	}
	return nil;
}

- (NSPoint)endHolePoint:(id)aEndHole {
	NSSize stringSize = [[self title] sizeWithAttributes:_stringAttributes];
	float heightOfText = stringSize.height;
	
	int hole =  [[self orderedHoles:[self inputs]] indexOfObject:aEndHole]+1;
	
	NSAssert( (hole <= [[self inputs] count]),@"hole should be within Inputs range in endholePoint:");
	return [self convertPoint:NSMakePoint(5+4,[self bounds].origin.y+[self bounds].size.height - [self verticalOffset] - heightOfText * (hole+1.0)) toView:[self superview]];
}

- (NSPoint)startHolePoint:(id) aStartHole {
	NSSize stringSize = [[self title] sizeWithAttributes:_stringAttributes];
	float heightOfText = stringSize.height;
	
	int hole =  [[self orderedHoles:[self outputs]] indexOfObject:aStartHole]+1;
	
	NSAssert( (hole <= [[self outputs] count]),@"hole should be within Outputs range in startholePoint:");
	return [self convertPoint:NSMakePoint([self bounds].origin.x+[self bounds].size.width-5-4, [self bounds].origin.y+[self bounds].size.height - [self verticalOffset] - heightOfText * (hole+1.0)) toView:[self superview]];
}

- (NSSize) minimalSize {
	NSSize titleSize = [[self title] sizeWithAttributes:_stringAttributes];
	float maxInputWidth = 0;
	int i;
	for (i=0; i<[[self inputs] count]; i++) {
		NSString* inputLabel = [[[self orderedInputs] objectAtIndex:(unsigned)i] valueForKey:@"label"];
		float inputWidth = 10+4+[inputLabel sizeWithAttributes:_stringAttributes].width + 5;
		maxInputWidth = MAX(inputWidth,maxInputWidth);
	}
	float maxOutputWidth = 0;
	int j;
	for (j=0; j<[[self outputs] count]; j++) {
		NSString* outputLabel = [[[self orderedOutputs] objectAtIndex:(unsigned)j] valueForKey:@"label"];
		float outputWidth =10+4+[outputLabel sizeWithAttributes:_stringAttributes].width + 5;
		maxOutputWidth = MAX(outputWidth,maxOutputWidth);
	}
	
	NSSize result;
	result.width = MAX(titleSize.width+16,maxInputWidth+maxOutputWidth); 
	result.height = (titleSize.height)*(2.0+(([[self inputs] count]>[[self outputs] count])?[[self inputs] count]:[[self outputs] count])) + [self verticalOffset]+12;
	return result;
}

#pragma mark -
#pragma mark *** drawing ***

- (void)drawRect:(NSRect)rect {
	NSRect bounds = NSInsetRect([self bounds],4,4);
	const float backgroundAlpha = 0.7;
	NSSize stringSize = [[self title] sizeWithAttributes:_stringAttributes];
	//draw body background
	[[[[self titleColor] blendedColorWithFraction:0.8 ofColor:[NSColor controlBackgroundColor]]colorWithAlphaComponent:backgroundAlpha] setFill];
	[[NSBezierPath bezierPathWithBottomRoundedRect:NSMakeRect(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height - stringSize.height) radius:8] fill];
	
	//draw title background
	[[NSBezierPath bezierPathWithTopRoundedRect:NSMakeRect(bounds.origin.x, bounds.origin.y + bounds.size.height - stringSize.height, bounds.size.width, stringSize.height) radius:8] gradientFillWithColor:[[self titleColor] colorWithAlphaComponent:backgroundAlpha]];
	
	//draw title
	[[self title] drawAtPoint:NSMakePoint(bounds.origin.x + (bounds.size.width -stringSize.width)/2,bounds.origin.y + bounds.size.height - stringSize.height) withAttributes:_stringAttributes];
	
	// draw end of lace
	for (NSDictionary *aDict in [self inputs]) {
		NSBezierPath *path = [NSBezierPath bezierPath];
		[path setLineWidth:1];
		[[NSColor grayColor] set];
		NSPoint end = [self convertPoint: [self endHolePoint:aDict] fromView:[self superview]];
		[path appendBezierPathWithOvalInRect:NSMakeRect(end.x-3,end.y-3,6,6)];
		[path stroke];
		NSPoint labelOrigin;
		NSString *inputLabel = [aDict valueForKey:@"label"];
		labelOrigin.x = end.x +5;
		labelOrigin.y = end.y - stringSize.height/2;
		[[NSColor blackColor] set];
		[inputLabel drawAtPoint:labelOrigin withAttributes:_stringAttributes];
	}
	
	// draw start of lace
	for (NSDictionary *aDict in [self outputs]) {
		NSBezierPath *path = [NSBezierPath bezierPath];
		[path setLineWidth:1];
		[[NSColor grayColor] set];
		NSPoint start = [self convertPoint: [self startHolePoint:aDict] fromView:[self superview]];
		[path appendBezierPathWithOvalInRect:NSMakeRect(start.x-3,start.y-3,6,6)];
		[path stroke];
		NSPoint labelOrigin;
		NSString *outputLabel = [aDict valueForKey:@"label"];
		labelOrigin.x = start.x - 5 - [outputLabel sizeWithAttributes:_stringAttributes].width;
		labelOrigin.y = start.y - stringSize.height/2;
		[[NSColor blackColor] set];
		[outputLabel drawAtPoint:labelOrigin withAttributes:_stringAttributes];
	}
	
	//draw outline
	[(([self isSelected])&&([NSGraphicsContext currentContextDrawingToScreen]))?[NSColor selectedControlColor]:[NSColor controlShadowColor] /*_titleColor*/ setStroke];
	float lineWidth = (([self isSelected])&&([NSGraphicsContext currentContextDrawingToScreen]))?2.0:1.0;
	NSBezierPath *shape = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(bounds,-lineWidth/2+0.15,-lineWidth/2+0.15) radius:8]; //0.15 to be perfect on a zoomed printing
	[shape setLineWidth:lineWidth];
	[shape stroke];
}

-(void)setFrame:(NSRect)aRect {
	NSRect orFrame = [self frame];
	if (orFrame.origin.x != aRect.origin.x) {
		[self willChangeValueForKey:@"originX"];
		[self willChangeValueForKey:@"drawingBounds"];
	}
	if (orFrame.origin.y != aRect.origin.y) {
		[self willChangeValueForKey:@"originY"];
		[self willChangeValueForKey:@"drawingBounds"];
	}
	if (orFrame.size.height != aRect.size.height) {
		[self willChangeValueForKey:@"height"];
		[self willChangeValueForKey:@"drawingBounds"];
	}
	if (orFrame.size.width != aRect.size.width) {
		[self willChangeValueForKey:@"width"];
		[self willChangeValueForKey:@"drawingBounds"];
	}
	
	[super setFrame:aRect];
	
	if (orFrame.origin.x != aRect.origin.x) {
		[self didChangeValueForKey:@"originX"];
		[self didChangeValueForKey:@"drawingBounds"];
	}
	if (orFrame.origin.y != aRect.origin.y) {
		[self didChangeValueForKey:@"originY"];
		[self didChangeValueForKey:@"drawingBounds"];
	}
	if (orFrame.size.height != aRect.size.height) {
		[self didChangeValueForKey:@"height"];
		[self didChangeValueForKey:@"drawingBounds"];
	}
	if (orFrame.size.width != aRect.size.width) {
		[self didChangeValueForKey:@"width"];
		[self didChangeValueForKey:@"drawingBounds"];
	}
}

#pragma mark -
#pragma mark *** events ***

- (BOOL) acceptsFirstResponder {
	return YES;
}

- (NSView *)hitTest:(NSPoint)aPoint {
	return (([self startHole:aPoint] != nil) || ([self endHole:aPoint] != nil))?nil:[super hitTest:aPoint]; 
}

- (void)mouseDown:(NSEvent*)theEvent {
	EFLaceView* sView = (EFLaceView*)[self superview];
	
	if ([theEvent modifierFlags] & NSShiftKeyMask){
		// add to selection
		[sView selectView:self state:YES];
	} else if ([theEvent modifierFlags] & NSCommandKeyMask){
		// inverse selection
		[sView selectView:self state:!self.isSelected];
	} else if (!self.isSelected) {
		[sView deselectViews];
		[sView selectView:self state:YES];
	}
	
	BOOL keepOn = YES;
	
	NSPoint mouseLoc;
	NSPoint lastMouseLoc = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];;
	NSRect initialFrame = [self frame];
	
	while (keepOn) {
        theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask | NSPeriodicMask ];
        switch ([theEvent type]) {
            case NSLeftMouseDragged: {
				[[NSCursor closedHandCursor] set];
				mouseLoc = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
				for (NSView* view in [sView selectedSubViews]) {
					[view setFrame: NSOffsetRect([view frame],mouseLoc.x-lastMouseLoc.x,mouseLoc.y-lastMouseLoc.y)];
				}
				lastMouseLoc = mouseLoc;
				[self autoscroll:theEvent];
				[sView setNeedsDisplay:YES];
				break;
			}
            case NSLeftMouseUp:
				[[NSCursor arrowCursor] set];
				if (!NSContainsRect([sView bounds],[self frame])) { 
					// revert to original frame if not inside superview
					[self setFrame:initialFrame];
					[sView setNeedsDisplay:YES];
				}
				keepOn = NO;
				[sView setNeedsDisplay:YES];
				break;
            default:
				/* Ignore any other kind of event. */
				break;
        }
    };
    return;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (((keyPath == @"inputs") || keyPath == @"outputs") && (context == _inoutputObservationContext)) {
		
		NSSet *new = [change valueForKey:@"new"];
		NSSet *old = [change valueForKey:@"old"];
		
		//compute inserted labels
		NSMutableSet *inserted = [new mutableCopy];
		[inserted minusSet:old];
		
		//compute removed labels
		NSMutableSet *removed = [old mutableCopy];
		[removed minusSet:new];
		
		//make label observed by the view for changes on label or on position
		for (id anObject in inserted) {
			[anObject addObserver:self forKeyPath:@"label" options:0 context:_inoutputObservationContext];
			[anObject addObserver:self forKeyPath:@"position" options:0 context:_inoutputObservationContext];
			[anObject addObserver:self forKeyPath:@"laces" options:0 context:_inoutputObservationContext];
		}
		
		for (id anObject in removed) {
			[anObject removeObserver:self forKeyPath:@"label"];
			[anObject removeObserver:self forKeyPath:@"position"];
			[anObject removeObserver:self forKeyPath:@"laces"];
		}
		
		//update size and redraw
		[self setWidth:MAX([self minimalSize].width,[self width])];
		[self setHeight:MAX([self minimalSize].height,[self height])];
		[[self superview] setNeedsDisplay:YES];
		
    }
	if ((keyPath == @"label") && (context == _inoutputObservationContext) ) {
		//update size and redraw
		[self setWidth:MAX([self minimalSize].width,[self width])];
		[self setHeight:MAX([self minimalSize].height,[self height])];
	}
	if ((keyPath == @"position") && (context == _inoutputObservationContext) ) {
		//redraw superview (laces may have changed because of positions of labels)
		[[self superview] setNeedsDisplay:YES];
	}
	if ([keyPath isEqualToString:@"laces"]) {
		//redraw laces because of undos
		[[self superview] setNeedsDisplay:YES];
	}
}
@end
