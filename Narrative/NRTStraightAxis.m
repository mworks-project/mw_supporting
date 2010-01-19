//
//  NRTStraightAxis.m
//  Narrative
//
//  Created by Drew McCormack on Tue Jul 16 2002.
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

#import "NRTStraightAxis.h"
#import "NRTStraightTick.h"
#import "NRTCoordinateIdentifiers.h"
#import "NRTTransform.h"

@implementation NRTStraightAxis

-(id)initWithCoordinateIdentifier:(id)coordIdentifier
    axisIdentifier:(id)axisIdentifier
    startViewPoint:(NSPoint)startPoint
    endViewPoint:(NSPoint)endPoint
{
    if ( self = [super initWithCoordinateIdentifier:coordIdentifier axisIdentifier:axisIdentifier] )
    {
        [self setStartViewPoint:startPoint];
        [self setEndViewPoint:endPoint];
    }
    return self;
}

-(NSPoint)startViewPoint
{
    return _startViewPoint;
}

-(void)setStartViewPoint:(NSPoint)point
{
    _startViewPoint = point;
}

-(NSPoint)endViewPoint
{
    return _endViewPoint;
}

-(void)setEndViewPoint:(NSPoint)point
{
    _endViewPoint = point;
}

// Return center point
-(NSPoint)principalPoint 
{
    NSPoint startPoint = [self startViewPoint];
    NSPoint endPoint = [self endViewPoint];
    return NSMakePoint( (startPoint.x + endPoint.x) * 0.5, (startPoint.y + endPoint.y) * 0.5 ); 
}

-(NSPoint)plotViewPointForAxisCoordinate:(float)coord
{
    NSDictionary *axisCoordDict;
    float axisCoord;
    NSPoint startPoint = [self startViewPoint];
    NSPoint endPoint = [self endViewPoint];
    axisCoordDict = [[self plotToAxisCoordinateTransform] transformedCoordinatesForBaseCoordinates:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:coord], [self coordinateIdentifier], nil] ];
    axisCoord = [[axisCoordDict objectForKey:NRTAxisCoordinate] floatValue];
    return NSMakePoint( startPoint.x + axisCoord * ( endPoint.x - startPoint.x ), 
        startPoint.y + axisCoord * ( endPoint.y - startPoint.y ) );
}

// Draw straight axis, then chain to super to draw ticks and labels.
-(void)drawInPlotView:(NRTPlotView *)plotView
{    
    [[self attributeForKey:NRTLineColorAttrib] set];
    [NSBezierPath setDefaultLineWidth:[[self attributeForKey:NRTLineWidthAttrib] floatValue]];
    [NSBezierPath strokeLineFromPoint:[self startViewPoint] toPoint:[self endViewPoint]];
    [super drawInPlotView:plotView];
}

@end
