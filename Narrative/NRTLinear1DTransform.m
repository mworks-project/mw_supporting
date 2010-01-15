//
//  NRTLinear1DTransform.m
//  Narrative
//
//  Created by Drew McCormack on Sun Sep 01 2002.
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

#import "NRTLinear1DTransform.h"


@implementation NRTLinear1DTransform

-(id)initWithBaseIdentifiers:(NSArray *)baseCoords
    andTransformedIdentifiers:(NSArray *)transformedCoords
{
    if ( self = [super initWithBaseIdentifiers:baseCoords andTransformedIdentifiers:transformedCoords] )
    {
        [self setTranslation:1.0];  // Initially identity
        [self setScalingFactor:1.0];
    }
    return self;
}

-(unsigned)numberOfBaseCoordinates
{
    return 1;
}

-(unsigned)numberOfTransformedCoordinates
{
    return 1;
}

-(void)setTranslation:(float)translation
{
    _translation = translation;
}

-(float)translation 
{
    return _translation;
}

-(void)setScalingFactor:(float)scale
{
    _scalingFactor = scale;
}

-(float)scalingFactor 
{
    return _scalingFactor;
}

// First applies translation, and then scales.
-(NSDictionary *)transformedCoordinatesForBaseCoordinates:(NSDictionary *)coords
{
    NSArray *baseIds = [self baseCoordinateIdentifiers];
    NSArray *transIds = [self transformedCoordinateIdentifiers];
    float base, trans;
    base = [[coords objectForKey:[baseIds objectAtIndex:0]] floatValue];
    trans = [self scalingFactor] * ( base + [self translation] );
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithFloat:trans], [transIds objectAtIndex:0], nil];
}

@end
