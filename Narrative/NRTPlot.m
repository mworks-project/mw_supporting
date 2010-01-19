//
//  NRTPlot.m
//  Narrative
//
//  Created by Drew McCormack on Thu Jan 01 1970.
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
//  MA  02111-1307  USA //

#import "NRTPlot.h"
#import "NRTDataClusterGraphic.h"
#import "NRTTransform.h"

@implementation NRTPlot

-(id)initWithIdentifier:(NSObject <NSCopying> *)ident andDataSource:(id)dataSource
{
    if ( self = [super init] ) 
    {
        [self setDataSource:dataSource];
        [self setIdentifier:ident];
    }
    return self;
}

-(id)initWithIdentifier:(id)ident
{
    return [self initWithIdentifier:ident andDataSource:nil];
}

-(id)init
{
    return [self initWithIdentifier:nil];
}

-(void)dealloc
{
    [_coordinatesToViewTransform release];
    [_clusterGraphic release];
    [_identifier release];
    [super dealloc];
}

// Abstract.
-(void)drawInPlotView:(NRTPlotView *)plotView
{
    [self doesNotRecognizeSelector:_cmd];
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

-(void)setDataSource:(id)ds
{
    _dataSource = ds; // Don't retain to avoid cycle retention problems
}

-(id)dataSource 
{
    return _dataSource;
}

// Also sets the transform of the cluster graphic being used.
-(void)setCoordinatesToViewTransform:(NRTTransform *)transform
{
    [transform retain];
    [_coordinatesToViewTransform release];
    _coordinatesToViewTransform = transform;
    [[self clusterGraphic] setCoordinatesToViewTransform:[self coordinatesToViewTransform]];
}

-(NRTTransform *)coordinatesToViewTransform
{
    return _coordinatesToViewTransform;
}

-(BOOL)dataSourceIsSetupToAllowDrawing
{
    // If no datasource, or basic methods are not defined, can't draw
    return 
        ( _dataSource &&
        [_dataSource respondsToSelector:@selector(numberOfDataClustersForPlot:)] &&
        [_dataSource respondsToSelector:@selector(clusterCoordinatesForPlot:andDataClusterIndex:)] );
}

// This also sets the transform of the cluster
-(void)setClusterGraphic:(NRTDataClusterGraphic *)graphic 
{
    [graphic retain];
    [_clusterGraphic release];
    _clusterGraphic = graphic;
    [_clusterGraphic setCoordinatesToViewTransform:[self coordinatesToViewTransform]];
}

-(NRTDataClusterGraphic *)clusterGraphic
{
    return _clusterGraphic;
}

@end
