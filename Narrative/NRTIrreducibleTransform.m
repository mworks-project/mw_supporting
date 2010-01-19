//
//  NRTIrreducibleTransform.m
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

#import "NRTIrreducibleTransform.h"


@implementation NRTIrreducibleTransform


-(id)initWithBaseIdentifiers:(NSArray *)baseCoords
    andTransformedIdentifiers:(NSArray *)transformedCoords
{
    if ( self = [super init] ) 
    {
        [self setBaseCoordinateIdentifiers:baseCoords];
        [self setTransformedCoordinateIdentifiers:transformedCoords];
    }
    return self;
}

-(void)dealloc
{
    [_baseCoordinateIdentifiers release];
    [_transformedCoordinateIdentifiers release];
    [super dealloc];
}

// Checks that the array passed has the correct number of base coordinates.
// If not, an exception is thrown.
-(void)setBaseCoordinateIdentifiers:(NSArray *)baseCoords
{
    NSAssert( [baseCoords count] == [self numberOfBaseCoordinates],
        @"Wrong number of entries in array in setBaseCoordinateIdentifiers:");
    [baseCoords retain];
    [_baseCoordinateIdentifiers release];
    _baseCoordinateIdentifiers = baseCoords;
}

-(NSArray *)baseCoordinateIdentifiers
{
    return _baseCoordinateIdentifiers;
}

-(void)setTransformedCoordinateIdentifiers:(NSArray *)transformedCoords
{
    NSAssert( [transformedCoords count] == [self numberOfTransformedCoordinates],
        @"Wrong number of entries in array in setTransformedCoordinateIdentifiers:" );
    [transformedCoords retain];
    [_transformedCoordinateIdentifiers release];
    _transformedCoordinateIdentifiers = transformedCoords;
}

-(NSArray *)transformedCoordinateIdentifiers
{
    return _transformedCoordinateIdentifiers;
}

@end
