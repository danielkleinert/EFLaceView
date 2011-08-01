//
//  EFView.h
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

#import <Cocoa/Cocoa.h>

@interface EFView : NSView  {
	int						_tag;
	NSString*				_title;
	NSColor*				_titleColor;
	NSMutableSet*			_inputs;
	NSMutableSet*			_outputs;
	float					_verticalOffset;
	NSMutableDictionary*	_stringAttributes;
	id						_data;
}

#pragma mark -
#pragma mark *** class ***


#pragma mark -
#pragma mark *** holes ***
- (NSArray *)orderedHoles:(NSSet *)aSet;
- (NSPoint)startHolePoint:(id) aStartHole;
- (NSPoint)endHolePoint:(id) aEndHole;
- (id)startHole:(NSPoint)aPoint;
- (id)endHole:(NSPoint)aPoint;

#pragma mark -
#pragma mark *** setters and accessors ***

// vertical offset
- (float)verticalOffset;
- (void)setVerticalOffset:(float)aValue;

// selected
- (BOOL)isSelected;

// title
- (NSString *)title;
- (void)setTitle:(NSString *)aTitle;

// title color
- (NSColor *)titleColor;
- (void)setTitleColor:(NSColor *)aColor;

#pragma mark drawingbounds
- (float) originX;
- (float) originY;
- (float) width;
- (float) height;
- (void) setOriginX:(float)aFloat;
- (void) setOriginY:(float)aFloat;
- (void) setWidth:(float)aFloat;
- (void) setHeight:(float)aFloat;

#pragma mark inputs and outputs
- (NSMutableSet*)inputs;
- (NSArray *)orderedInputs;

- (NSMutableSet *)outputs;
- (NSArray*)orderedOutputs;

#pragma mark -
#pragma mark *** geometry ***
- (NSSize) minimalSize;


@end
