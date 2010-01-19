//
//  NRTStraightTick.m
//  Narrative
//
//  Created by Drew McCormack on Sat Jul 20 2002.
//
//  Narrative -- a plotting framework for Cocoa and GNUStep. 
//  Copyright (C) 2003 Drew McCormack
// 
//  This library is free software; you can redistribute it 
//  and/or modify it under the terms of the GNU Lesser General 
//  Public License as published by the Free Software 
//  Foundation; either version 2.1 of the License, or 
//  (at your option) any later version. 
//
//  This library is distributed in the hope that it will be 
//  useful, but WITHOUT ANY WARRANTY; without even the implied 
//  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
//  See the GNU Lesser General Public License for more details. 
// 
//  You should have received a copy of the GNU Lesser General Public 
//  License along with this library; if not, write to the Free 
//  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, 
//  MA  02111-1307  USA 
//

#import "NRTStraightTick.h"


@implementation NRTStraightTick

-(id)initWithViewVector:(NSPoint)vecPoint
{
    if ( self = [super init] ) 
    {
        [self setPlotViewVectorPoint:vecPoint];
    }
    return self;
}

-(void)drawInPlotView:(NRTPlotView *)view atPoint:(NSPoint)point
{
    [[self attributeForKey:NRTLineColorAttrib] set];
    [NSBezierPath setDefaultLineWidth:[[self attributeForKey:NRTLineWidthAttrib] floatValue]];
    [NSBezierPath strokeLineFromPoint:point 
        toPoint:NSMakePoint(point.x + [self plotViewVectorPoint].x, point.y + [self plotViewVectorPoint].y)];
}

-(NSPoint)plotViewVectorPoint
{
    return _plotViewVectorPoint;
}

-(void)setPlotViewVectorPoint:(NSPoint)vector
{
    _plotViewVectorPoint = vector;
}

@end
