//
//  M80Defs.h
//  M80ImageMerger
//
//  Created by amao on 2017/9/12.
//  Copyright © 2017年 M80. All rights reserved.
//

#ifndef M80Defs_h
#define M80Defs_h

#define M80ImageThreshold (0.05)
#define M80ImageIgnoreOffset (64 * [[UIScreen mainScreen] scale] + 5)
#define M80PixelValueEqual(x,y) ((x) * 1.1 >= (y) && (x) * 0.9 <= (y))

#endif /* M80Defs_h */
