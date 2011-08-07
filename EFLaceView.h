//
//  EFLaceView.h
// EFLaceView
//
//  Created by MacBook Pro ef on 01/08/06.
//  Copyright 2006 Edouard FISCHER. All rights reserved.
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//	-	Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//	-	Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//	-	Neither the name of Edouard FISCHER nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Cocoa/Cocoa.h>
#import "EFView.h"

@interface EFLaceView : NSView
{
	NSObject*		_dataObjectsContainer;
    NSString*		_dataObjectsKeyPath;
	NSObject*		_selectionIndexesContainer;
    NSString*		_selectionIndexesKeyPath;
	
	NSArray*		_oldDataObjects;
	
	BOOL			_isMaking;
	
	NSPoint			_startPoint;
	NSPoint			_endPoint;
	NSPoint			_rubberStart;
	NSPoint			_rubberEnd;
	BOOL			_isRubbing;
	
	id				_startHole;
	id				_endHole;
	
	EFView*			_startSubView;
	EFView*			_endSubView;
	
	id				_delegate;
	
}


#pragma mark -
#pragma mark *** bindings ***

- (void)startObservingDataObjects:(NSArray *)dataObjects;
- (void)stopObservingDataObjects:(NSArray *)dataObjects;


#pragma mark -
#pragma mark *** setters and accessors

- (id)delegate;
- (void)setDelegate:(id)newDelegate;


- (NSMutableArray *)laces;

- (NSArray *)dataObjects;

- (NSIndexSet *)selectionIndexes;

- (NSArray *)oldDataObjects;
- (void)setOldDataObjects:(NSArray *)anOldDataObjects;

#pragma mark -
#pragma mark *** geometry ***

- (BOOL)isStartHole:(NSPoint)aPoint;
- (BOOL)isEndHole:(NSPoint)aPoint;
- (void)drawLinkFrom:(NSPoint)startPoint to:(NSPoint)endPoint color:(NSColor *)insideColor;
- (void)deselectViews;
- (void)selectView:(EFView *)aView;
- (void)selectView:(EFView *)aView state:(BOOL)aBool;
- (NSArray*)selectedSubViews;

- (void) connectHole:(id)startHole  toHole:(id)endHole;

@end

@interface NSObject (EFLaceViewDataObject)
+ (NSArray *)keysForNonBoundsProperties;
@end

@interface NSObject (EFLaceViewDelegateMethod)

- (BOOL)EFLaceView:(EFLaceView*)aView shouldSelectView:(EFView *)aView state:(BOOL)aBool;
- (BOOL)EFLaceView:(EFLaceView*)aView shouldSelectLace:(NSDictionary*)aLace;
- (BOOL)EFLaceView:(EFLaceView*)aView shouldConnectHole:(id)startHole toHole:(id)endHole;
- (BOOL)EFLaceView:(EFLaceView*)aView shouldDrawView:(EFView *)aView;

@end