//
//  NRTPlotArea.m
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

#import "NRTPlotArea.h"
#import "NRTPlotAreaComponent.h"
#import "NRTCoordinateIdentifiers.h"
#import "NRTTransform.h"


@interface NRTPlotArea (PrivateMethods)
-(void)setTransformForPlotAreaComponents;
@end


@implementation NRTPlotArea

-(id)initWithFrame:(NSRect)frame 
{
    if ( self = [super initWithFrame:frame] )
    {
        [self setPlotAreaComponents:[NSMutableArray array]];
    }
    return self;
}

-(void)dealloc
{
    [_plotCoordinateToViewTransform release];
    [_plotAreaComponents release];
    [super dealloc];
}

-(void)setTransformForPlotAreaComponents
{
    NSEnumerator *en = [[self plotAreaComponents] objectEnumerator];
    id <NRTPlotAreaComponent> component;
    while ( component = [en nextObject] )
    {
        [component setCoordinatesToViewTransform:[self plotCoordinateToViewTransform]];
    }
}

-(void)setPlotCoordinateToViewTransform:(NRTTransform *)trans
{
    [trans retain];
    [_plotCoordinateToViewTransform release];
    _plotCoordinateToViewTransform = trans;
    [self setTransformForPlotAreaComponents];
}

-(NRTTransform *)plotCoordinateToViewTransform
{
    return _plotCoordinateToViewTransform;
}

// Sets the components coords-to-view transform, and as well as
// adding the component to the NRTPlotView's list.
-(void)addPlotAreaComponent:(NSObject <NRTPlotAreaComponent> *)component
{
    [self addComponent:component];
    [[self plotAreaComponents] addObject:component];
    [component setCoordinatesToViewTransform:[self plotCoordinateToViewTransform]];
}

-(void)removeAllComponents
{
    [super removeAllComponents];
    [self setPlotAreaComponents:[NSMutableArray array]];
}

-(NSMutableArray *)plotAreaComponents
{
    return _plotAreaComponents;
}

-(void)setPlotAreaComponents:(NSMutableArray *)components
{
    [components retain];
    [_plotAreaComponents release];
    _plotAreaComponents = components;
    [self setTransformForPlotAreaComponents];
}

// Transforms to NSView coordinates from plotting coordinates.
-(NSPoint)plotViewPointForPlotCoordinates:(NSDictionary *)coords
{
    NSDictionary *transCoords;
    NSPoint point;
    transCoords = [[self plotCoordinateToViewTransform] transformedCoordinatesForBaseCoordinates:coords];
    point.x = [[transCoords objectForKey:NRTXPlotViewCoordinate] floatValue];
    point.y = [[transCoords objectForKey:NRTYPlotViewCoordinate] floatValue];
    return point;
}

@end
