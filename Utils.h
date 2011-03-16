#import <Cocoa/Cocoa.h>

@interface NSBezierPath(RoundedRectangle)
/*
 * Returns a closed bezier path describing a rectangle with curved corners
 * The corner radius will be trimmed to not exceed half of the lesser rectangle dimension.
 * <http://www.cocoadev.com/index.pl?RoundedRectangles>
 */
+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect) aRect radius:(float) radius;
+ (NSBezierPath*)bezierPathWithTopRoundedRect:(NSRect)aRect radius:(float)radius;
+ (NSBezierPath*)bezierPathWithBottomRoundedRect:(NSRect)aRect radius:(float)radius;

/* Fill a path with a gradient color - lighter at top, darker at bottom
 * <http://www.wilshipley.com/blog/2005/07/pimp-my-code-part-3-gradient.html>
 */
- (void)gradientFillWithColor:(NSColor*)color;
@end
