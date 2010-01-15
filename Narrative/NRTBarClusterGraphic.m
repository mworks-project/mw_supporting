//
//  NRTBarClusterGraphic.m
//  Narrative
//
//  Created by Drew McCormack on Sun Sep 22 2002.
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

#import "NRTBarClusterGraphic.h"
#import "NRTDataClusterIdentifiers.h"
#import "NRTCoordinateIdentifiers.h"
#import "NRTPlotArea.h"
#import "NRTDefines.h"
#import "NRTTransform.h"
#import "NRTExceptions.h"


@implementation NRTBarClusterGraphic

-(id)initWithBarWidth:(float)barWidth
{
    if ( self = [super init] ) 
    {
        [self setBarWidth:barWidth];
        [self setBarBaseCoordinate:0.0];
    }
    return self;
}

-(void)setBarWidth:(float)barWidth
{
    _barWidth = barWidth;
}

-(float)barWidth 
{
    return _barWidth;
}

-(void)setBarBaseCoordinate:(float)barBaseCoord 
{
    _barBaseCoordinate = barBaseCoord;
}

-(float)barBaseCoordinate 
{
    return _barBaseCoordinate;
}

-(NSDictionary *)principalCoordinates
{
    NSDictionary *clusterCoords = [self clusterCoordinates];
    NSNumber *xNum = [clusterCoords objectForKey:NRTXClusterIdentifier];
    NSNumber *yNum = [clusterCoords objectForKey:NRTYClusterIdentifier];
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [[xNum copy] autorelease], NRTXCoordinateIdentifier,
        [[yNum copy] autorelease], NRTYCoordinateIdentifier, nil];
}

// NRTTransform must be set before calling this method, or an exception will be
// thrown.
-(void)drawInPlotView:(NRTPlotView *)plotView
{
    
    // Make sure the transform is set
    if ( ! [self coordinatesToViewTransform] )
        [NSException raise:NRTException 
            format:@"coordinatesToViewTransform not set in drawInPlotView:"];
            
    // Create bezier path for rect
    // First determine the plot view point
    NSNumber *xCoord = [[self clusterCoordinates] objectForKey:NRTXClusterIdentifier];
    NSNumber *yCoord = [[self clusterCoordinates] objectForKey:NRTYClusterIdentifier];
    NSDictionary *plotViewCoords = 
        [[self coordinatesToViewTransform] transformedCoordinatesForBaseCoordinates:
            [NSDictionary dictionaryWithObjectsAndKeys:
                xCoord,		NRTXCoordinateIdentifier,
                yCoord,		NRTYCoordinateIdentifier,
                nil]];
        
    // Now determine the base of the bar in the plot view
    yCoord = [NSNumber numberWithFloat:[self barBaseCoordinate]];
    NSDictionary *basePlotViewCoords = 
        [[self coordinatesToViewTransform] transformedCoordinatesForBaseCoordinates:
            [NSDictionary dictionaryWithObjectsAndKeys:
                xCoord,		NRTXCoordinateIdentifier,
                yCoord, 	NRTYCoordinateIdentifier, nil]];
                
    float xPlotViewCoord = [[plotViewCoords objectForKey:NRTXPlotViewCoordinate] floatValue];
    float yPlotViewCoord = [[plotViewCoords objectForKey:NRTYPlotViewCoordinate] floatValue];
    float yBasePlotViewCoord = [[basePlotViewCoords objectForKey:NRTYPlotViewCoordinate] floatValue];
    NSRect rect = NSMakeRect( xPlotViewCoord - 0.5 * [self barWidth], yBasePlotViewCoord, 
        [self barWidth], yPlotViewCoord - yBasePlotViewCoord );
    NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRect:rect];
        
    // Fill rect
    [[self attributeForKey:NRTFillColorAttrib] set];
    [bezierPath fill];
    
    // Stroke edge of rect
    [bezierPath setLineWidth:[[self attributeForKey:NRTLineWidthAttrib] floatValue]];    
    [[self attributeForKey:NRTLineColorAttrib] set];
    [bezierPath stroke];

}

@end