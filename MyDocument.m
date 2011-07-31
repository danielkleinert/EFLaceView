//
//  MyDocument.m
//  EFLaceViewCoreData
//
//  Created by MacBook Pro ef on 06/08/06.
//  Copyright 2006 Edouard FISCHER. All rights reserved.
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//	-	Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//	-	Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//	-	Neither the name of Edouard FISCHER nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "MyDocument.h"

@implementation MyDocument

- (id)init {
    self = [super init];
    if (self != nil) {
        // initialization code
    }
    return self;
}

- (void)windowWillClose:(NSNotification *)aNotification {
	if ([myView isDescendantOf: [[aNotification valueForKey:@"object"] contentView]]) {
		[myView unbind:@"dataObjects"];
		[myView unbind:@"selectionIndexes"];
	}
}

- (void) dealloc {	
	[super dealloc];
}

- (NSString *)windowNibName {
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
    [super windowControllerDidLoadNib:windowController];
    // user interface preparation code
	[myView bind: @"dataObjects" toObject: controller withKeyPath:@"arrangedObjects" options:nil];
	[myView bind: @"selectionIndexes" toObject: controller withKeyPath:@"selectionIndexes" options:nil];
}

- (void)printShowingPrintPanel:(BOOL)showPanels {
    // Obtain a custom view that will be printed
    NSView *printView = myView;
	[[self printInfo] setHorizontalPagination:NSFitPagination];
	[[self printInfo] setVerticalPagination:NSFitPagination];
	[[self printInfo] setOrientation:NSLandscapeOrientation];
    // Construct the print operation and setup Print panel
    NSPrintOperation *op = [NSPrintOperation printOperationWithView:printView printInfo:[self printInfo]];
    [op setShowsPrintPanel:showPanels];
    if (showPanels) {
        // Add accessory view, if needed
    }
	
    // Run operation, which shows the Print panel if showPanels was YES
    [self runModalPrintOperation:op delegate:nil didRunSelector:NULL contextInfo:NULL];
}

@end
