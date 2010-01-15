//
//  NRTScatterPlot.m
//  Narrative
//
//  Created by Drew McCormack on Fri Jul 12 2002.
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

#import "NRTScatterPlot.h"
#import "NRTDataClusterIdentifiers.h"
#import "NRTPlotDataSource.h"
#import "NRTDataClusterGraphic.h"
#import "NRTTransform.h"
#import "NRTCoordinateIdentifiers.h"
#import "NRTExceptions.h"

@implementation NRTScatterPlot

-(id)initWithIdentifier:(NSObject <NSCopying> *)identifier andDataSource:(id)dataSource 
{
    if ( self = [super initWithIdentifier:identifier andDataSource:dataSource] ) 
    {
        [self setConnectPoints:YES];
    }
    return self;
}

-(void)setConnectPoints:(BOOL)connectPoints 
{
    _connectPoints = connectPoints;
}

-(BOOL)connectPoints
{
    return _connectPoints;
}

-(void)drawInPlotView:(NRTPlotView *)plotView
{
    unsigned numPoints, pointIndex;
    id ds;
    float x, y, xPrevious, yPrevious;

    if ( nil == [self clusterGraphic] ) 
        [NSException raise:NRTException format:@"NRTPlot does not have a clusterGraphic"];
    if ( ! [self dataSourceIsSetupToAllowDrawing] ) return;
    ds = [self dataSource];

    numPoints = [ds numberOfDataClustersForPlot:self];
    
    // First draw lines joining points
    if ( [self connectPoints] ) 
    {
        for ( pointIndex = 0; pointIndex < numPoints; ++pointIndex ) 
        {
            NSDictionary *clusterCoords = [ds clusterCoordinatesForPlot:self andDataClusterIndex:pointIndex];
            NSDictionary *coords, *plotViewCoords;
            NRTTransform *transform = [self coordinatesToViewTransform];
            NRTDataClusterGraphic *clusterGraphic = [self clusterGraphic];
            [clusterGraphic setClusterCoordinates:clusterCoords];
            coords = [clusterGraphic principalCoordinates];
            NSAssert( nil != coords, @"coords was nil in drawInPlotView:relativeToPoint:" );
            NSAssert( nil != transform, @"transform was nil in drawInPlotView:relativeToPoint:" );
            plotViewCoords = [transform transformedCoordinatesForBaseCoordinates:coords];
            NSAssert( nil != plotViewCoords, @"plotViewCoords was nil in drawInPlotView:relativeToPoint:" );
            x = [[plotViewCoords objectForKey:NRTXPlotViewCoordinate] floatValue];
            y = [[plotViewCoords objectForKey:NRTYPlotViewCoordinate] floatValue];
            [[self attributeForKey:NRTLineColorAttrib] set];
            [NSBezierPath setDefaultLineWidth:[[self attributeForKey:NRTLineWidthAttrib] floatValue]];
            if ( pointIndex > 0 ) 
                [NSBezierPath strokeLineFromPoint:NSMakePoint(xPrevious, yPrevious) 
                    toPoint:NSMakePoint(x, y)];
            xPrevious = x;
            yPrevious = y;
        }
    }
    
    // Now draw symbols on top of lines
    for ( pointIndex = 0; pointIndex < numPoints; ++pointIndex ) 
    {
        NSDictionary *clusterCoords = [ds clusterCoordinatesForPlot:self andDataClusterIndex:pointIndex];
        NRTDataClusterGraphic *clusterGraphic = [self clusterGraphic];
        [clusterGraphic setClusterCoordinates:clusterCoords];
        [clusterGraphic drawInPlotView:plotView];
    }

}

@end
