//
//  NRTChainedTransform.m
//  Narrative
//
//  Created by Drew McCormack on Sat Sep 14 2002.
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

#import "NRTChainedTransform.h"


@implementation NRTChainedTransform

-(NSDictionary *)transformedCoordinatesForBaseCoordinates:(NSDictionary *)coords 
{
    NSEnumerator *subTransEnum = [[self subTransforms] objectEnumerator];
    NRTTransform *subTrans;
    NSDictionary *currentCoords = coords;
    while ( subTrans = [subTransEnum nextObject] ) 
    {
        currentCoords = [subTrans transformedCoordinatesForBaseCoordinates:currentCoords];
    }
    return currentCoords;
}

// This will just be the number of base coords in the first sub transform.
-(unsigned)numberOfBaseCoordinates 
{
    NSAssert( [[self subTransforms] count] > 0, @"Zero base coordinates in NRTChainedTransform" );
    return [[[self subTransforms] objectAtIndex:0] numberOfBaseCoordinates];
}

// This will just be the number of base coords in the last sub transform.
-(unsigned)numberOfTransformedCoordinates
{
    NSAssert( [[self subTransforms] count] > 0, @"Zero transformed coordinates in NRTChainedTransform" );
    return [[[self subTransforms] lastObject] numberOfTransformedCoordinates];
}

-(NSArray *)baseCoordinateIdentifiers 
{
    NSAssert( [[self subTransforms] count] > 0, @"Zero base coordinates in NRTChainedTransform" );
    return [[[self subTransforms] objectAtIndex:0] baseCoordinateIdentifiers];
}

-(NSArray *)transformedCoordinateIdentifiers
{
    NSAssert( [[self subTransforms] count] > 0, @"Zero transformed coordinates in NRTChainedTransform" );
    return [[[self subTransforms] lastObject] transformedCoordinateIdentifiers];
}

@end