//
//  NRTSymbolClusterGraphic.m
//  Narrative
//
//  Created by Drew McCormack on Sat Jul 13 2002.
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

#import "NRTSymbolClusterGraphic.h"
#import "NRTDataClusterIdentifiers.h"
#import "NRTCoordinateIdentifiers.h"
#import "NRTPlotArea.h"
#import "NRTDefines.h"
#import "NRTTransform.h"
#import "NRTExceptions.h"

@implementation NRTSymbolClusterGraphic

-(id)initWithBezierPath:(NSBezierPath *)path
{
    if ( self = [super init] ) 
    {
        [self setBezierPath:path];
    }
    return self;
}

-(void)dealloc
{
    [_bezierPath release];
    [super dealloc];
}

-(NSSize)size
{
    return _size;
}

-(void)setSize:(NSSize)size
{
    _size = size;
}

-(NSBezierPath *)bezierPath
{
    return _bezierPath;
}

-(void)setBezierPath:(NSBezierPath *)path
{
    [path retain];
    [_bezierPath release];
    _bezierPath = path;
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
    NSRect bezierBounds;
    NSDictionary *centerPointInView;
    float centerX, centerY;
    NSAffineTransform *pathToViewTransform;
    NSBezierPath *viewPath;
    
    // If there is no bezier path, don't draw anything
    if ( ! [self bezierPath] ) return;
    
    // If the display cluster variable is false, don't draw
    id shouldDisplayId = nil;
    if ( ( shouldDisplayId = [[self clusterCoordinates] objectForKey:NRTShouldDisplayClusterIdentifier] ) &&
        ![shouldDisplayId boolValue] ) return;
    
    // Make sure the transform is set
    if ( ! [self coordinatesToViewTransform] )
        [NSException raise:NRTException 
            format:@"coordinatesToViewTransform not set in drawInPlotView:"];
    
    bezierBounds = [[self bezierPath] bounds];
    centerPointInView = 
        [[self coordinatesToViewTransform] transformedCoordinatesForBaseCoordinates:[self principalCoordinates]];
    centerX = [[centerPointInView objectForKey:NRTXPlotViewCoordinate] floatValue];
    centerY = [[centerPointInView objectForKey:NRTYPlotViewCoordinate] floatValue];
    
    pathToViewTransform = [NSAffineTransform transform];        
    if ( NRTFloatIsZero(bezierBounds.size.width) ||  NRTFloatIsZero(bezierBounds.size.height) )
        [NSException raise:NRTDivideByZeroError format:@"Width or height of bezier path was zero."];
    [pathToViewTransform translateXBy:( centerX - NSMidX( bezierBounds ) ) 
        yBy:( centerY - NSMidY( bezierBounds ) )];
    [pathToViewTransform scaleXBy:( [self size].width / bezierBounds.size.width )
        yBy:( [self size].height / bezierBounds.size.height ) ];
        
    viewPath = [pathToViewTransform transformBezierPath:[self bezierPath]];
    
    [viewPath setLineWidth:[[self attributeForKey:NRTLineWidthAttrib] floatValue]];
    
    [[self attributeForKey:NRTFillColorAttrib] set];
    [viewPath fill];
    
    [[self attributeForKey:NRTLineColorAttrib] set];
    [viewPath stroke];
    
}

@end
