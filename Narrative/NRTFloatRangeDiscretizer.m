//
//  NRTFloatRangeDiscretizer.m
//  Narrative
//
//  Created by Drew McCormack on Sat Oct 05 2002.
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

#import "NRTFloatRangeDiscretizer.h"
#include <math.h>


@implementation NRTFloatRangeDiscretizer

-(id)initWithFloatRange:(NRTFloatRange)range desiredNumberOfPoints:(unsigned)points 
    useOnlyRoundNumbers:(BOOL)round
{
    if ( self = [super init] ) 
    {
        [self setFloatRange:range];
        [self setDesiredNumberOfDiscretePoints:points];
        [self setUseOnlyRoundNumbers:round];
    }
    return self;
}

-(id)initWithFloatRange:(NRTFloatRange)range desiredNumberOfPoints:(unsigned)points
{
    return [self initWithFloatRange:range desiredNumberOfPoints:points useOnlyRoundNumbers:NO];
}

-(id)initWithFloatRange:(NRTFloatRange)range
{
    return [self initWithFloatRange:range desiredNumberOfPoints:10];
}

-(NRTFloatRange)floatRange 
{
    return _floatRange;
}

-(void)setFloatRange:(NRTFloatRange)range
{
    _floatRange = range;
}

-(void)setUseOnlyRoundNumbers:(BOOL)roundNumbers
{
    _useOnlyRoundNumbers = roundNumbers;
}

-(BOOL)useOnlyRoundNumbers
{
    return _useOnlyRoundNumbers;
}

-(void)setDesiredNumberOfDiscretePoints:(unsigned)num
{
    _desiredNumberOfDiscretePoints = num;
}

-(unsigned)desiredNumberOfDiscretePoints
{
    return _desiredNumberOfDiscretePoints;
}

-(NSArray *)discretePoints
{
    NSMutableArray *points = [NSMutableArray array];
    unsigned numPoints, numIntervals;
    float interval;
    numPoints = [self desiredNumberOfDiscretePoints];
    
    // If no points are desired, create no points
    if ( numPoints == 0 ) return points;
    
    // Take account of possible divide by zeros
    numIntervals = MAX( 1, (int)numPoints - 1 );
    interval = [self floatRange].length / numIntervals;
    
    // Adjust interval and number of points if we can only use round numbers
    if ( [self useOnlyRoundNumbers] ) 
    {
        // Determine round number using the NSString with scientific format of numbers
        NSString *intervalInSciFormat = [NSString stringWithFormat:@"%e", interval];
        NSScanner *scanner = [NSScanner scannerWithString:intervalInSciFormat];
        int mostSignificantDigit, exponent;
        NSAssert( [scanner scanInt:&mostSignificantDigit], @"Failed to scan most significant integer");
        
        // Ignore decimal part of scientific number
        NSAssert( [scanner scanUpToString:@"e" intoString:nil] && [scanner scanString:@"e" intoString:nil],
            @"Failed to correctly scan the exponential 'e' in scientific number" );
            
        // Scan the exponent
        NSAssert( [scanner scanInt:&exponent], @"Failed to correctly scan exponent" );
        
        // Set interval which has been rounded. Make sure it is not zero.
        interval = ( mostSignificantDigit == 0 ? 1 : mostSignificantDigit ) * pow( 10.0, (float)exponent );
        
        // Determine how many points there should be now
        numPoints = MAX( 0, floor( [self floatRange].length / interval ) ) + 1;
    
    }
    
    float pointPosition = [self floatRange].location;
    unsigned i;
    for ( i = 0; i < numPoints; ++i) 
    {
        [points addObject:[NSNumber numberWithFloat:pointPosition]];
        pointPosition += interval;
    }
    
    return points;
}


@end
