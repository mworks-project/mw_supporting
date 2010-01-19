//
//  NRTAffineTransform.m
//  Narrative
//
//  Created by Drew McCormack on Wed Aug 14 2002.
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

#import "NRTAffineTransform.h"


@implementation NRTAffineTransform

-(id)initWithBaseIdentifiers:(NSArray *)baseCoords
    andTransformedIdentifiers:(NSArray *)transformedCoords
{
    if ( self = [super initWithBaseIdentifiers:baseCoords andTransformedIdentifiers:transformedCoords] )
    {
        [self setTransform:[NSAffineTransform transform]];  // Initially set identity matrix
    }
    return self;
}

-(void)dealloc
{
    [_transform release];
    [super dealloc];
}

-(unsigned)numberOfBaseCoordinates
{
    return 2;
}

-(unsigned)numberOfTransformedCoordinates
{
    return 2;
}

-(NSAffineTransform *)transform
{
    return _transform;
}
 
-(void)setTransform:(NSAffineTransform *)trans
{
    [trans retain];
    [_transform release];
    _transform = trans;
}

-(NSDictionary *)transformedCoordinatesForBaseCoordinates:(NSDictionary *)coords
{
    NSArray *baseIds = [self baseCoordinateIdentifiers];
    NSArray *transIds = [self transformedCoordinateIdentifiers];
    float baseX, baseY;
    NSPoint transPoint;
    baseX = [[coords objectForKey:[baseIds objectAtIndex:0]] floatValue];
    baseY = [[coords objectForKey:[baseIds objectAtIndex:1]] floatValue];
    transPoint = [[self transform] transformPoint:NSMakePoint(baseX, baseY)];
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithFloat:transPoint.x], [transIds objectAtIndex:0],
        [NSNumber numberWithFloat:transPoint.y], [transIds objectAtIndex:1], nil];
}

@end
