//
//  NRTAxis.m
//  Narrative
//
//  Created by Drew McCormack on Sat May 25 2002.
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

#import "NRTAxis.h"
#import "NRTAxisTick.h"
#import "NRTPlotView.h"
#import "NRTTransform.h"
#import "NRTAxisLabel.h"
#import "NRTAxisTitle.h"

@implementation NRTAxis

// Designated Constructor
-(id)initWithCoordinateIdentifier:(id)coordIdentifier
    axisIdentifier:(id)axisIdentifier;
{
    if ( self = [super init] )
    {
        [self setTickPositions:nil];
        [self setPatternOfTicks:nil];
        [self setTickLabels:nil];
        [self setTitle:nil];
        [self setIdentifier:axisIdentifier];
        [self setCoordinateIdentifier:coordIdentifier];
        [self setPlotToAxisCoordinateTransform:nil];
    }
    return self;
}

-(id)init
{
    return 
        [self initWithCoordinateIdentifier:nil axisIdentifier:nil];
}

-(void)dealloc
{
    [_tickPositions release];
    [_patternOfTicks release];
    [_tickLabels release];
    [_identifier release];
    [_coordinateIdentifier release];
    [_plotToAxisCoordinateTransform release];
    [_title release];
    [super dealloc];
}

-(NSPoint)principalPoint 
{
    [self doesNotRecognizeSelector:_cmd];
    return NSMakePoint( 0, 0 );
}

-(void)setIdentifier:(NSObject <NSCopying> *)ident 
{
    [_identifier autorelease];
    _identifier = [ident copy];
}

-(NSObject <NSCopying> *)identifier 
{
    return _identifier;
}

-(NSObject <NSCopying> *)coordinateIdentifier
{
    return _coordinateIdentifier;
}

-(void)setCoordinateIdentifier:(NSObject <NSCopying> *)coordIdentifier
{
    [_coordinateIdentifier autorelease];
    _coordinateIdentifier = [coordIdentifier copy];
}

-(NRTTransform *)plotToAxisCoordinateTransform
{
    return _plotToAxisCoordinateTransform;
}

-(void)setPlotToAxisCoordinateTransform:(NRTTransform *)transform
{
    [transform retain];
    [_plotToAxisCoordinateTransform release];
    _plotToAxisCoordinateTransform = transform;
}

// This method draws ticks and labels, but not the axis. In the subclass, the axis should
// be drawn, and this method called to draw ticks and labels.
-(void)drawInPlotView:(NRTPlotView *)plotView
{
    unsigned numPositions = [[self tickPositions] count];
    unsigned numTicksInPattern = [[self patternOfTicks] count];
    unsigned tickIndex;
    
    if ( numTicksInPattern == 0 ) return;
    
    for ( tickIndex = 0; tickIndex < numPositions; tickIndex++ ) 
    {
        NSNumber *coord = [_tickPositions objectAtIndex:tickIndex];
        NSPoint plotViewPoint = [self plotViewPointForAxisCoordinate:[coord floatValue]];
        NRTAxisTick *tick = [_patternOfTicks objectAtIndex:( tickIndex % numTicksInPattern )];        
        [tick drawInPlotView:plotView atPoint:plotViewPoint];
        
        // Now the label. Only draw this if it exists.
        if ( tickIndex >= [_tickLabels count] ) continue;
        NRTAxisLabel *label = [_tickLabels objectAtIndex:tickIndex];
        [label drawInPlotView:plotView atPoint:plotViewPoint];
    }
    
    [[self title] drawInPlotView:plotView atPoint:NSMakePoint( [self principalPoint].x, [self principalPoint].y)];
    
}

// Ticks
-(NSArray *)tickPositions
{
    return _tickPositions;
}

-(void)setTickPositions:(NSArray *)positions
{
    [_tickPositions autorelease];
    _tickPositions = [positions retain];
}

-(NSArray *)patternOfTicks
{
    return _patternOfTicks;
}

-(void)setPatternOfTicks:(NSArray *)tickPattern
{
    [_patternOfTicks autorelease];
    _patternOfTicks = [tickPattern retain];
}

// Labels
-(NSArray *)tickLabels
{
    return _tickLabels;
}

-(void)setTickLabels:(NSArray *)labels
{
    [_tickLabels autorelease];
    _tickLabels = [labels retain];
}

-(NRTAxisTitle *)title {
    return _title;
}

-(void)setTitle:(NRTAxisTitle *)title {
    [_title autorelease];
    _title = [title retain];
}

-(NSPoint)plotViewPointForAxisCoordinate:(float)coord
{
    [self doesNotRecognizeSelector:_cmd];
    return NSMakePoint( 0, 0 );
}

@end
