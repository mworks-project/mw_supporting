//
//  NRTOHLCClusterGraphic.m
//  Narrative
//
//  Created by Drew McCormack on Sat Sep 21 2002.
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

#import "NRTOHLCClusterGraphic.h"
#import "NRTDataClusterIdentifiers.h"
#import "NRTCoordinateIdentifiers.h"
#import "NRTPlotArea.h"
#import "NRTDefines.h"
#import "NRTTransform.h"
#import "NRTExceptions.h"


@implementation NRTOHLCClusterGraphic

-(id)initWithWidth:(float)width
{
    if ( self = [super init] ) 
    {
        [self setWidth:width];
    }
    return self;
}

-(void)setWidth:(float)width
{
    _width = width;
}

-(float)width 
{
    return _width;
}

-(NSDictionary *)principalCoordinates
{
    NSDictionary *clusterCoords = [self clusterCoordinates];
    NSNumber *xNum = [clusterCoords objectForKey:NRTXClusterIdentifier];
    NSNumber *closeNum = [clusterCoords objectForKey:NRTCloseClusterIdentifier];
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [[xNum copy] autorelease], NRTXCoordinateIdentifier,
        [[closeNum copy] autorelease], NRTYCoordinateIdentifier, nil];
}

// NRTTransform must be set before calling this method, or an exception will be
// thrown.
-(void)drawInPlotView:(NRTPlotView *)plotView
{
    
    // Make sure the transform is set
    if ( ! [self coordinatesToViewTransform] )
        [NSException raise:NRTException 
            format:@"coordinatesToViewTransform not set in drawInPlotView:"];
            
    // Set the line width and color
    [NSBezierPath setDefaultLineWidth:[[self attributeForKey:NRTLineWidthAttrib] floatValue]];    
    [[self attributeForKey:NRTLineColorAttrib] set];
    
    // Draw central vertical line
    NSDictionary *clusterCoords = [self clusterCoordinates];
    NSNumber *xCoord = [clusterCoords objectForKey:NRTXClusterIdentifier];
    NSNumber *lowCoord = [clusterCoords objectForKey:NRTLowClusterIdentifier];
    NSNumber *highCoord = [clusterCoords objectForKey:NRTHighClusterIdentifier];
    NSDictionary *centralPointInView;
    NSPoint lowCentralPoint, highCentralPoint;
    centralPointInView = 
        [[self coordinatesToViewTransform] transformedCoordinatesForBaseCoordinates:
            [NSDictionary dictionaryWithObjectsAndKeys:
                xCoord,		NRTXCoordinateIdentifier,
                lowCoord, 	NRTYCoordinateIdentifier, nil]];
    lowCentralPoint = NSMakePoint( [[centralPointInView objectForKey:NRTXPlotViewCoordinate] floatValue],
        [[centralPointInView objectForKey:NRTYPlotViewCoordinate] floatValue] );
    centralPointInView = 
        [[self coordinatesToViewTransform] transformedCoordinatesForBaseCoordinates:
            [NSDictionary dictionaryWithObjectsAndKeys:
                xCoord,		NRTXCoordinateIdentifier,
                highCoord, 	NRTYCoordinateIdentifier, nil]];
    highCentralPoint = NSMakePoint( [[centralPointInView objectForKey:NRTXPlotViewCoordinate] floatValue],
        [[centralPointInView objectForKey:NRTYPlotViewCoordinate] floatValue] );
    [NSBezierPath strokeLineFromPoint:lowCentralPoint toPoint:highCentralPoint];
    
    // Draw close tick
    NSNumber *closeCoord = [clusterCoords objectForKey:NRTCloseClusterIdentifier];
    NSNumber *openCoord  = [clusterCoords objectForKey:NRTOpenClusterIdentifier];
    NSPoint closeCentralPoint, openCentralPoint;
    centralPointInView = 
        [[self coordinatesToViewTransform] transformedCoordinatesForBaseCoordinates:
            [NSDictionary dictionaryWithObjectsAndKeys:
                xCoord,		NRTXCoordinateIdentifier,
                closeCoord, 	NRTYCoordinateIdentifier, nil]];
    closeCentralPoint = NSMakePoint( [[centralPointInView objectForKey:NRTXPlotViewCoordinate] floatValue],
        [[centralPointInView objectForKey:NRTYPlotViewCoordinate] floatValue] );

    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:0.5 * [self width] yBy:0.0];
    [NSBezierPath strokeLineFromPoint:closeCentralPoint toPoint:[transform transformPoint:closeCentralPoint]];
        
    // Draw open tick
    centralPointInView = 
        [[self coordinatesToViewTransform] transformedCoordinatesForBaseCoordinates:
            [NSDictionary dictionaryWithObjectsAndKeys:
                xCoord,		NRTXCoordinateIdentifier,
                openCoord, 	NRTYCoordinateIdentifier, nil]];
    openCentralPoint = NSMakePoint( [[centralPointInView objectForKey:NRTXPlotViewCoordinate] floatValue],
        [[centralPointInView objectForKey:NRTYPlotViewCoordinate] floatValue] );
        
    transform = [NSAffineTransform transform];
    [transform translateXBy:-0.5 * [self width] yBy:0.0];
    [NSBezierPath strokeLineFromPoint:openCentralPoint toPoint:[transform transformPoint:openCentralPoint]];

}

@end
