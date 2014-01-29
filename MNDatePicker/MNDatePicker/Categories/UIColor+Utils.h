//
//  UIColor+Utils.h
//

@interface UIColor (Utils)

// Function to pass component values from 0 to 255 instead of from 0 to 1
#define colorWithRGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define colorWithRGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@end