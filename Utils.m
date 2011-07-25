#import "Utils.h"


// CoreGraphics gradient helpers
typedef struct {
  CGFloat red1, green1, blue1, alpha1;
  CGFloat red2, green2, blue2, alpha2;
} _twoColorsType;

void _linearColorBlendFunction(void *info, const CGFloat *in, CGFloat *out);
void _linearColorBlendFunction(void *info, const CGFloat *in, CGFloat *out) {
  _twoColorsType *twoColors = info;
  out[0] = (1.0 - *in) * twoColors->red1 + *in * twoColors->red2;
  out[1] = (1.0 - *in) * twoColors->green1 + *in * twoColors->green2;
  out[2] = (1.0 - *in) * twoColors->blue1 + *in * twoColors->blue2;
  out[3] = (1.0 - *in) * twoColors->alpha1 + *in * twoColors->alpha2;
}

void _linearColorReleaseInfoFunction(void *info);
void _linearColorReleaseInfoFunction(void *info) {
  free(info);
}

static const CGFunctionCallbacks linearFunctionCallbacks = {0, &_linearColorBlendFunction, &_linearColorReleaseInfoFunction};
static const CGFloat domainAndRange[8] = {0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0};



@implementation NSBezierPath(RoundedRectangle)
+ (NSBezierPath*)bezierPathWithRoundedRect:(NSRect)aRect radius:(float)radius {
   NSBezierPath* path = [self bezierPath];
   //radius = MIN(radius, 0.5f * MIN(NSWidth(aRect), NSHeight(aRect)));
   NSRect rect = NSInsetRect(aRect, radius, radius);
   [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect)) radius:radius startAngle:180.0 endAngle:270.0];
   [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMinY(rect)) radius:radius startAngle:270.0 endAngle:360.0];
   [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMaxY(rect)) radius:radius startAngle:  0.0 endAngle: 90.0];
   [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMaxY(rect)) radius:radius startAngle: 90.0 endAngle:180.0];
   [path closePath];
   return path;
}

+ (NSBezierPath*)bezierPathWithTopRoundedRect:(NSRect)aRect radius:(float)radius {
   NSBezierPath* path = [self bezierPath];
   //radius = MIN(radius, 0.5f * MIN(NSWidth(aRect), NSHeight(aRect)));
   NSRect rect = NSInsetRect(aRect, radius, radius);
   [path moveToPoint:NSMakePoint(NSMinX(aRect) , NSMinY(aRect))];
   [path lineToPoint:NSMakePoint(NSMaxX(aRect) , NSMinY(aRect) )];
   [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMaxY(rect)) radius:radius startAngle:  0.0 endAngle: 90.0];
   [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMaxY(rect)) radius:radius startAngle: 90.0 endAngle:180.0];
   [path closePath];
   return path;
}

+ (NSBezierPath*)bezierPathWithBottomRoundedRect:(NSRect)aRect radius:(float)radius {
   NSBezierPath* path = [self bezierPath];
   //radius = MIN(radius, 0.5f * MIN(NSWidth(aRect), NSHeight(aRect)));
   NSRect rect = NSInsetRect(aRect, radius, radius);
   [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect)) radius:radius startAngle:180.0 endAngle:270.0];
   [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMinY(rect)) radius:radius startAngle:270.0 endAngle:360.0];
   [path lineToPoint:NSMakePoint(NSMaxX(aRect), NSMaxY(aRect))];
   [path lineToPoint:NSMakePoint(NSMinX(aRect), NSMaxY(aRect))];
   [path closePath];
   return path;
}

- (void)gradientFillWithColor:(NSColor*)color {
	// Take the color apart
	CGFloat hue, saturation, brightness, alpha;
	[[color colorUsingColorSpaceName:NSDeviceRGBColorSpace] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
	// Create synthetic darker and lighter versions
	NSColor *lighterColor = [NSColor colorWithDeviceHue:hue saturation:MAX(0.0, saturation-.12) brightness:MIN(1.0,brightness+0.30) alpha:alpha];
	NSColor *darkerColor = [NSColor colorWithDeviceHue:hue saturation:MIN(1.0, (saturation > .04) ? saturation+0.12 : 0.0) brightness:MAX(0.0, brightness-0.045) alpha:alpha];
	
	//lighterColor = [[color blendedColorWithFraction:0.7 ofColor:[NSColor whiteColor]] colorUsingColorSpaceName:NSDeviceRGBColorSpace];		
	//darkerColor = [[color blendedColorWithFraction:0.15 ofColor:[NSColor blackColor]] colorUsingColorSpaceName:NSDeviceRGBColorSpace];		
		
	// Set up the helper function for drawing washes
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_twoColorsType *twoColors = malloc(sizeof(_twoColorsType)); 
	[lighterColor getRed:&twoColors->red1 green:&twoColors->green1 blue:&twoColors->blue1 alpha:&twoColors->alpha1];
	[darkerColor getRed:&twoColors->red2 green:&twoColors->green2 blue:&twoColors->blue2 alpha:&twoColors->alpha2];
	CGFunctionRef linearBlendFunctionRef = CGFunctionCreate(twoColors, 1, domainAndRange, 4, domainAndRange, &linearFunctionCallbacks);  
	NSRect bounds = [self bounds];
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSaveGState(context); 
	[self addClip];
	{	CGShadingRef cgShading = CGShadingCreateAxial(colorSpace,CGPointMake(0, NSMaxY(bounds)), CGPointMake(0, NSMinY(bounds)), linearBlendFunctionRef, NO, NO);
		CGContextDrawShading(context, cgShading);
		CGShadingRelease(cgShading);
    } 
	CGContextRestoreGState(context);
	CGFunctionRelease(linearBlendFunctionRef);
	CGColorSpaceRelease(colorSpace);	
}
@end
