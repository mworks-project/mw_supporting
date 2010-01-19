//
//  NRTXYChart.m
//  Narrative
//
//  Created by Drew McCormack on Sat Sep 14 2002.
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

#import "NRTXYChart.h"
#import "NRTStraightAxis.h"
#import "NRTStraightTick.h"
#import "NRTChartAttributeStrings.h"
#import "NRTLinear1DTransform.h"
#import "NRTOrthogonalTransform.h"
#import "NRTCoordinateIdentifiers.h"
#import "NRTPlotArea.h"
#import "NRTAxisLabel.h"
#import "NRTAxisTitle.h"

@interface NRTXYChart (PrivateMethods)
-(NRTAxis *)createPlotViewAxisForAttributePrefix:(NSString *)prefixString tickUnitVector:(NSPoint)tickVec
    labelDisplacementVector:(NSPoint)labelDisplaceVec titleDisplacementVector:(NSPoint)titleDisplaceVec
    titleRotation:(float)titleRotation coordinateIdentifier:(NSString *)coordIdentifier
    startViewPoint:(NSPoint)startPoint endViewPoint:(NSPoint)endPoint;
@end

@implementation NRTXYChart

+(NSDictionary *)defaultAttributesDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:
            [[NSBundle bundleForClass:self] pathForResource:@"XYChartDefaults" ofType:@"plist"]];
    [dict addEntriesFromDictionary:[super defaultAttributesDictionary]];
    return dict;
}

// Transforms from X coordinate to NRTPlotArea X bounds coordinates.
-(NRTTransform *)createXPlotAreaTransform
{
    float minXCoord = [[[self attributeForKey:NRTBottomXAxisCoordinateRangeCA] objectAtIndex:0] floatValue];
    float maxXCoord = [[[self attributeForKey:NRTBottomXAxisCoordinateRangeCA] objectAtIndex:1] floatValue];
    float minXFrame = [[[self attributeForKey:NRTPlotAreaFrameXRangeCA] objectAtIndex:0] floatValue];
    float maxXFrame = [[[self attributeForKey:NRTPlotAreaFrameXRangeCA] objectAtIndex:1] floatValue];
    
    NSAssert( minXCoord < maxXCoord, @"Invalid X coordinate range in createXTransform" );
    NSAssert( minXFrame < maxXFrame, @"Invalid X frame range in createXTransform" );
    
    NRTLinear1DTransform *trans = [[[NRTLinear1DTransform alloc] 
        initWithBaseIdentifiers:[NSArray arrayWithObject:NRTXCoordinateIdentifier]
        andTransformedIdentifiers:[NSArray arrayWithObject:NRTXPlotViewCoordinate]] autorelease];
    [trans setTranslation:(-minXCoord)]; // Assume bounds origin is at 0.0
    [trans setScalingFactor:( ( maxXFrame - minXFrame ) / (maxXCoord - minXCoord ) ) ];
    
    return trans;
}

-(NRTTransform *)createYPlotAreaTransform 
{
    float minYCoord = [[[self attributeForKey:NRTLeftYAxisCoordinateRangeCA] objectAtIndex:0] floatValue];
    float maxYCoord = [[[self attributeForKey:NRTLeftYAxisCoordinateRangeCA] objectAtIndex:1] floatValue];
    float minYFrame = [[[self attributeForKey:NRTPlotAreaFrameYRangeCA] objectAtIndex:0] floatValue];
    float maxYFrame = [[[self attributeForKey:NRTPlotAreaFrameYRangeCA] objectAtIndex:1] floatValue];
    
    NSAssert( minYCoord < maxYCoord, @"Invalid Y coordinate range in createYTransform" );
    NSAssert( minYFrame < maxYFrame, @"Invalid Y frame range in createYTransform" );
    
    NRTLinear1DTransform *trans = [[[NRTLinear1DTransform alloc] 
        initWithBaseIdentifiers:[NSArray arrayWithObject:NRTYCoordinateIdentifier]
        andTransformedIdentifiers:[NSArray arrayWithObject:NRTYPlotViewCoordinate]] autorelease];
    [trans setTranslation:(-minYCoord)]; // Assume bounds origin is at 0.0
    [trans setScalingFactor:( ( maxYFrame - minYFrame ) / (maxYCoord - minYCoord ) ) ];
    
    return trans;
}

-(NRTTransform *)createPlotAreaTransform
{
    return [[[NRTOrthogonalTransform alloc] initWithSubTransforms:
        [NSArray arrayWithObjects:[self createXPlotAreaTransform], [self createYPlotAreaTransform], nil] ]
        autorelease];
}

-(NRTPlotArea *)createPlotArea
{
    float minXFrame = [[[self attributeForKey:NRTPlotAreaFrameXRangeCA] objectAtIndex:0] floatValue];
    float maxXFrame = [[[self attributeForKey:NRTPlotAreaFrameXRangeCA] objectAtIndex:1] floatValue];
    float minYFrame = [[[self attributeForKey:NRTPlotAreaFrameYRangeCA] objectAtIndex:0] floatValue];
    float maxYFrame = [[[self attributeForKey:NRTPlotAreaFrameYRangeCA] objectAtIndex:1] floatValue];
    NSRect areaFrame = NSMakeRect( minXFrame, minYFrame, ( maxXFrame - minXFrame ), 
        ( maxYFrame - minYFrame ) );
    NRTPlotArea *pa = [[[NRTPlotArea alloc] initWithFrame:areaFrame] autorelease];
    [pa setPlotCoordinateToViewTransform:[self createPlotAreaTransform]];
    
    // Set background color of area
    NSArray *rgba = [self attributeForKey:NRTPlotAreaBackgroundRGBACA];
    NSColor *backgroundColor = 
        [NSColor colorWithCalibratedRed:[[rgba objectAtIndex:0] floatValue]
                    green:[[rgba objectAtIndex:1] floatValue]
                    blue:[[rgba objectAtIndex:2] floatValue]
                    alpha:[[rgba objectAtIndex:3] floatValue]];
    [pa setBackgroundColor:backgroundColor];
    
    return pa;
}

// Private method
-(NRTAxis *)createPlotViewAxisForAttributePrefix:(NSString *)prefixString tickUnitVector:(NSPoint)tickVec
    labelDisplacementVector:(NSPoint)labelDisplaceVec titleDisplacementVector:(NSPoint)titleDisplaceVec
    titleRotation:(float)titleRotation coordinateIdentifier:(NSString *)coordIdentifier
    startViewPoint:(NSPoint)startPoint endViewPoint:(NSPoint)endPoint
{
    float minCoord = [[[self attributeForKey:
        [prefixString stringByAppendingString:@"CoordinateRangeCA"]] objectAtIndex:0] floatValue];
    float maxCoord = [[[self attributeForKey:
        [prefixString stringByAppendingString:@"CoordinateRangeCA"]] objectAtIndex:1] floatValue];
    
    NRTStraightAxis *axis = [[[NRTStraightAxis alloc] initWithCoordinateIdentifier:coordIdentifier
        axisIdentifier:prefixString startViewPoint:startPoint endViewPoint:endPoint ] autorelease];
    
    // Set line width and color
    NSArray *rgb = [self attributeForKey:[prefixString stringByAppendingString:@"RGBCA"]];
    NSColor *axisColor = 
        [NSColor colorWithCalibratedRed:[[rgb objectAtIndex:0] floatValue]
                    green:[[rgb objectAtIndex:1] floatValue]
                    blue:[[rgb objectAtIndex:2] floatValue]
                    alpha:1.0];
    [axis setAttribute:axisColor forKey:NRTLineColorAttrib];
    [axis setAttribute:[self attributeForKey:[prefixString stringByAppendingString:@"WidthCA"]]
        forKey:NRTLineWidthAttrib];
        
    // Set transform to axis coordinate
    NRTLinear1DTransform *trans = [[[NRTLinear1DTransform alloc] 
        initWithBaseIdentifiers:[NSArray arrayWithObject:NRTXCoordinateIdentifier]
        andTransformedIdentifiers:[NSArray arrayWithObject:NRTAxisCoordinate]] autorelease];
    NSAssert( minCoord < maxCoord, @"Invalid coordinate range in createPlotViewAxisForAttributePrefix:" );
    [trans setTranslation:(-minCoord)];
    [trans setScalingFactor:( 1.0 / (maxCoord - minCoord ) ) ];
    [axis setPlotToAxisCoordinateTransform:trans];
    
    // Set ticks
    float majorTickLength = 
        [[self attributeForKey:[prefixString stringByAppendingString:@"MajorTickLengthCA"]] floatValue];
    float minorTickLength = 
        [[self attributeForKey:[prefixString stringByAppendingString:@"MinorTickLengthCA"]] floatValue];
    NRTStraightTick *majorTick = [[[NRTStraightTick alloc] initWithViewVector:
        NSMakePoint( tickVec.x * majorTickLength, tickVec.y * majorTickLength )] autorelease];
    [majorTick setAttribute:[self attributeForKey:
        [prefixString stringByAppendingString:@"MajorTickWidthCA"]] forKey:NRTLineWidthAttrib];
    NRTStraightTick *minorTick = [[[NRTStraightTick alloc] initWithViewVector:
        NSMakePoint( tickVec.x * minorTickLength, tickVec.y * minorTickLength )] autorelease];
    [minorTick setAttribute:[self attributeForKey:[prefixString stringByAppendingString:@"MinorTickWidthCA"]] 
        forKey:NRTLineWidthAttrib];
    [minorTick setAttribute:axisColor forKey:NRTLineColorAttrib]; // Same color for ticks as axis
    [majorTick setAttribute:axisColor forKey:NRTLineColorAttrib];
    
    // Ticks
    int tickIndex, numMinorPerMajor = [[self attributeForKey:
        [prefixString stringByAppendingString:@"MinorTicksPerMajorTickCA"]] intValue];
    NSMutableArray *ticksArray = [NSMutableArray array];
    [ticksArray addObject:majorTick];
    for ( tickIndex = 0; tickIndex < numMinorPerMajor; tickIndex++ ) 
    {
        [ticksArray addObject:minorTick];
    }
    [axis setPatternOfTicks:ticksArray];
    
    // Tick positions
    NSArray *tickPositions = [self attributeForKey:[prefixString stringByAppendingString:@"TickCoordinatesCA"]];
    [axis setTickPositions:tickPositions];
    
    // Labels for ticks
    float labelDisplacement = 
        [[self attributeForKey:[prefixString stringByAppendingString:@"LabelsOffsetCA"]] floatValue];
    NSAffineTransform *labelTrans = [NSAffineTransform transform];
    [labelTrans translateXBy:( labelDisplaceVec.x * labelDisplacement ) 
        yBy:( labelDisplaceVec.y * labelDisplacement ) ];
    NSMutableArray *tickLabels = [NSMutableArray array];
    NSEnumerator *tickLabelStringsEnum = [[self attributeForKey:
        [prefixString stringByAppendingString:@"LabelsCA"]] objectEnumerator];
    NSString *tickLabelString;
    while ( tickLabelString = [tickLabelStringsEnum nextObject] ) 
    {
        NSString *fontName = [self attributeForKey:[prefixString stringByAppendingString:@"LabelsFontCA"]];
        float fontSize = [[self attributeForKey:[prefixString stringByAppendingString:@"LabelsFontSizeCA"]] floatValue];
        NSArray *rgbArray = [self attributeForKey:[prefixString stringByAppendingString:@"LabelsFontRGBCA"]];
        NSAttributedString *attribString = 
            [[[NSAttributedString alloc] initWithString:tickLabelString attributes:
                [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSFont fontWithName:fontName size:fontSize], NSFontAttributeName,
                    [NSColor colorWithCalibratedRed:[[rgbArray objectAtIndex:0] floatValue]
                        green:[[rgbArray objectAtIndex:1] floatValue]
                        blue:[[rgbArray objectAtIndex:2] floatValue]
                        alpha:1.0], NSForegroundColorAttributeName, 
                    nil]] autorelease];
        [tickLabels addObject:[NRTAxisLabel annotationWithAttributedString:attribString andAffineTransform:labelTrans]];
    }
    [axis setTickLabels:tickLabels];
    
    // NRTAxis title
    NSString *title = [self attributeForKey:[prefixString stringByAppendingString:@"TitleCA"]];
    NSArray *rgbArray = [self attributeForKey:[prefixString stringByAppendingString:@"TitleFontRGBCA"]];
    float fontSize = [[self attributeForKey:[prefixString stringByAppendingString:@"TitleFontSizeCA"]] floatValue];
    NSString *fontName = [self attributeForKey:[prefixString stringByAppendingString:@"TitleFontCA"]];
    
    NSAttributedString *attribString = 
        [[[NSAttributedString alloc] initWithString:title attributes:
            [NSDictionary dictionaryWithObjectsAndKeys:
                [NSFont fontWithName:fontName size:fontSize], NSFontAttributeName,
                [NSColor colorWithCalibratedRed:[[rgbArray objectAtIndex:0] floatValue]
                    green:[[rgbArray objectAtIndex:1] floatValue]
                    blue:[[rgbArray objectAtIndex:2] floatValue]
                    alpha:1.0], NSForegroundColorAttributeName, 
                nil]] autorelease];
                
    NSAffineTransform *titleTrans = [NSAffineTransform transform];
    float titleOffset = [[self attributeForKey:[prefixString stringByAppendingString:@"TitleOffsetCA"]] floatValue];
    float xTrans = titleOffset * titleDisplaceVec.x;
    float yTrans = titleOffset * titleDisplaceVec.y;
    [titleTrans translateXBy:xTrans yBy:yTrans];
    [titleTrans rotateByDegrees:titleRotation];
    [axis setTitle:[[[NRTAxisTitle alloc] initWithAttributedString:attribString
        andAffineTransform:titleTrans] autorelease]];

    return axis;
}

-(NRTAxis *)createBottomXPlotViewAxis 
{
    NRTPlotArea *area = [self plotArea];
    return [self createPlotViewAxisForAttributePrefix:@"NRTBottomXAxis" tickUnitVector:NSMakePoint(0.0, -1.0)
        labelDisplacementVector:NSMakePoint(0.0, -1.0) titleDisplacementVector:NSMakePoint(0.0, -1.0)
        titleRotation:0.0 coordinateIdentifier:NRTXCoordinateIdentifier
        startViewPoint:NSMakePoint( NSMinX( [area frame] ), NSMinY( [area frame] ) )
        endViewPoint:NSMakePoint( NSMaxX( [area frame] ), NSMinY( [area frame] ) ) ];
}

-(NRTAxis *)createTopXPlotViewAxis 
{
    NRTPlotArea *area = [self plotArea];
    return [self createPlotViewAxisForAttributePrefix:@"NRTTopXAxis" tickUnitVector:NSMakePoint(0.0, 1.0)
        labelDisplacementVector:NSMakePoint(0.0, 1.0) titleDisplacementVector:NSMakePoint(0.0, 1.0)
        titleRotation:0.0 coordinateIdentifier:NRTXCoordinateIdentifier
        startViewPoint:NSMakePoint( NSMinX( [area frame] ), NSMaxY( [area frame] ) )
        endViewPoint:NSMakePoint( NSMaxX( [area frame] ), NSMaxY( [area frame] ) ) ];
}

-(NRTAxis *)createLeftYPlotViewAxis
{
    NRTPlotArea *area = [self plotArea];
    return [self createPlotViewAxisForAttributePrefix:@"NRTLeftYAxis" tickUnitVector:NSMakePoint(-1.0, 0.0)
        labelDisplacementVector:NSMakePoint(-1.0, 0.0) titleDisplacementVector:NSMakePoint(-1.0, 0.0)
        titleRotation:90.0 coordinateIdentifier:NRTYCoordinateIdentifier
        startViewPoint:NSMakePoint( NSMinX( [area frame] ), NSMinY( [area frame] ) )
        endViewPoint:NSMakePoint( NSMinX( [area frame] ), NSMaxY( [area frame] ) ) ];
}

-(NRTAxis *)createRightYPlotViewAxis
{
    NRTPlotArea *area = [self plotArea];
    return [self createPlotViewAxisForAttributePrefix:@"NRTRightYAxis" tickUnitVector:NSMakePoint(1.0, 0.0)
        labelDisplacementVector:NSMakePoint(1.0, 0.0) titleDisplacementVector:NSMakePoint(1.0, 0.0)
        titleRotation:-90.0 coordinateIdentifier:NRTYCoordinateIdentifier
        startViewPoint:NSMakePoint( NSMaxX( [area frame] ), NSMinY( [area frame] ) )
        endViewPoint:NSMakePoint( NSMaxX( [area frame] ), NSMaxY( [area frame] ) ) ];
}

-(NSArray *)createPlotViewAxes
{
    return [NSArray arrayWithObjects:
        [self createBottomXPlotViewAxis], 
        [self createLeftYPlotViewAxis], 
        [self createTopXPlotViewAxis],
        [self createRightYPlotViewAxis], nil];
}

@end
