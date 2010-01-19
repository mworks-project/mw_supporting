//
//  NRTChart.m
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
//  MA  02111-1307  USA //

#import "NRTChart.h"
#import "NRTPlotArea.h"
#import "NRTPlot.h"
#import "NRTAxis.h"
#import "NRTPlotViewAnnotation.h"
#import "NRTChartAttributeStrings.h"

@implementation NRTChart

// Designated
- (id)initWithFrame:(NSRect)frame
{
    if ( self = [super initWithFrame:frame] )
    {
        [self setAttributesDictionary:[[[self class] defaultAttributesDictionary] mutableCopy]];
        [self setPlots:[NSMutableArray array]];
    }
    return self;
}

-(void)dealloc
{
    [_plots release];
    [_plotArea release];
    [_attributesDictionary release];
    [super dealloc];
}

-(void)setDelegate:(id)delegate
{
    _delegate = delegate;
}

-(id)delegate {
    return _delegate;
}

// Subclasses chain to this method to get superclasses defaults.
+(NSDictionary *)defaultAttributesDictionary 
{
    return [NSDictionary dictionaryWithContentsOfFile:
            [[NSBundle  bundleForClass:self] pathForResource:@"ChartDefaults" ofType:@"plist"]];
}

-(NSMutableDictionary *)attributesDictionary
{
    return _attributesDictionary;
}

-(void)setAttributesDictionary:(NSMutableDictionary *)dict
{
    [_attributesDictionary autorelease];
    _attributesDictionary = [dict retain];
}

-(void)setAttributesFromDictionary:(NSDictionary *)dict
{
    [_attributesDictionary addEntriesFromDictionary:dict];
}

-(void)setAttribute:(id)obj forKey:(NSObject <NSCopying> *)key
{
    NSAssert( (key != nil) && (obj != nil), @"Attempt to set an attribute in NRTChart with a nil value" );
    [_attributesDictionary setObject:obj forKey:key];
}

-(id)attributeForKey:(NSObject <NSCopying> *)key {
    return [_attributesDictionary objectForKey:key];
}

// Stores plot area, but also makes plot area a subview
-(void)setPlotArea:(NRTPlotArea *)plotArea 
{
    [_plotArea removeFromSuperview];
    [plotArea retain];
    [_plotArea release];
    _plotArea = plotArea;
    if ( _plotArea ) [self addSubview:_plotArea];
}

-(NRTPlotArea *)plotArea 
{
    return _plotArea;
}

// Adding and removing plots
-(void)addPlot:(NRTPlot *)plot
{
    [[self plots] addObject:plot];
    [self setNeedsLayout:YES];
}

-(void)removeAllPlots 
{
    [[self plots] removeAllObjects];
    [self setNeedsLayout:YES];
}

-(NSMutableArray *)plots 
{
    return _plots;
}

-(void)setPlots:(NSMutableArray *)plots 
{
    [_plots autorelease];
    _plots = [plots retain];
}

-(void)setChartsOwnAttributes {
    // Set background color of chart
    NSArray *rgba = [self attributeForKey:NRTChartBackgroundRGBACA];
    NSColor *backgroundColor = 
        [NSColor colorWithCalibratedRed:[[rgba objectAtIndex:0] floatValue]
                    green:[[rgba objectAtIndex:1] floatValue]
                    blue:[[rgba objectAtIndex:2] floatValue]
                    alpha:[[rgba objectAtIndex:3] floatValue]];
    [self setBackgroundColor:backgroundColor];
}

// Override in subclasses if needed, but chain to this method.
-(void)layout
{
    id del = [self delegate];
    
    // First remove existing components from view
    [self removeAllComponents];
    
    // Set charts own attributes
    [self setChartsOwnAttributes];
        
    // Create a plot area. Inform delegate. Delegate can block creation.
    BOOL shouldCreate = YES;
    if ( del && [del respondsToSelector:@selector(chartShouldCreatePlotArea:)] )
        shouldCreate = [del chartShouldCreatePlotArea:self];
        
    if ( shouldCreate ) {
        [self setPlotArea:[self createPlotArea]];
        
        // Inform delegate of creation
        if ( del && [del respondsToSelector:@selector(chart:didCreatePlotArea:)] )
            [del chart:self didCreatePlotArea:[self plotArea]];
    }
    
    // Add plots to plot area
    NSEnumerator *plotEnum = [[self plots] objectEnumerator];
    NRTPlot *plot = nil;
    while ( plot = [plotEnum nextObject] ) 
    {
        BOOL addPlot = YES;
        
        if ( del && [del respondsToSelector:@selector(chart:shouldAddPlot:toPlotArea:)] )
            addPlot = [del chart:self shouldAddPlot:plot toPlotArea:[self plotArea]];
            
        if ( addPlot ) {
            [[self plotArea] addPlotAreaComponent:plot];        
            if ( del && [del respondsToSelector:@selector(chart:didAddPlot:toPlotArea:)] )
            	[del chart:self didAddPlot:plot toPlotArea:[self plotArea]];
        }
    }
    
    // Create title, and add to view
    BOOL createTitle = YES;
    if ( del && [del respondsToSelector:@selector(chartShouldCreateTitle:)] )
        createTitle = [del chartShouldCreateTitle:self];
    if ( createTitle ) {
        id title = [self createTitle];
        [self addComponent:title];
        if ( del && [del respondsToSelector:@selector(chart:didCreateTitle:)] )
            [del chart:self didCreateTitle:title];
    }
    
    // Create and add plot view axes
    BOOL createPlotViewAxes = YES;
    if ( del && [del respondsToSelector:@selector(chartShouldCreatePlotViewAxes:)] ) 
        createPlotViewAxes = [del chartShouldCreatePlotViewAxes:self];
        
    if ( createPlotViewAxes ) {
        NSArray *axes = [self createPlotViewAxes];
        NSEnumerator *axesEnum = [axes objectEnumerator];
        NRTAxis *axis;
            
        while ( axis = [axesEnum nextObject] )
        {
            [self addComponent:axis];
        }
        
        if ( del && [del respondsToSelector:@selector(chart:didCreatePlotViewAxes:)] ) 
            [del chart:self didCreatePlotViewAxes:axes];
    }
    
    // Create and add plot area axes
    BOOL createPlotAreaAxes = YES;
    if ( del && [del respondsToSelector:@selector(chartShouldCreatePlotAreaAxes:)] ) 
        createPlotAreaAxes = [del chartShouldCreatePlotAreaAxes:self];
        
    if ( createPlotAreaAxes ) {
        NSArray *axes = [self createPlotAreaAxes];
        NSEnumerator *axesEnum = [axes objectEnumerator];
        NRTAxis *axis;
        
        while ( axis = [axesEnum nextObject] )
        {
            [[self plotArea] addPlotAreaComponent:axis];
        }
        
        if ( del && [del respondsToSelector:@selector(chart:didCreatePlotAreaAxes:)] ) 
            [del chart:self didCreatePlotAreaAxes:axes];
    }
        
    [self setNeedsLayout:NO];

}

// factory methods
// Default plot area is inset by 33%
-(NRTPlotArea *)createPlotArea
{
    NSRect frame = [self frame];
    return [[[NRTPlotArea alloc] initWithFrame:
        NSInsetRect(frame, NSWidth(frame)/6., NSHeight(frame)/6. )] autorelease];
}

// Only those axes drawn in the chart, not those drawn in the plot area. This can return
// an empty array
-(NSArray *)createPlotViewAxes 
{
    return [NSArray array];
}

// Only those axes drawn in the plot area. Can be empty.
-(NSArray *)createPlotAreaAxes 
{
    return [NSArray array];
}

-(NRTPlotViewAnnotation *)createTitle
{
    NSString *title = [self attributeForKey:NRTTitleCA];
    NSArray *rgbArray = [self attributeForKey:NRTTitleRGBCA];
    float fontSize = [[self attributeForKey:NRTTitleFontSizeCA] floatValue];
    NSString *fontName = [self attributeForKey:NRTTitleFontCA];
    
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
    NSArray *plotViewVector = [self attributeForKey:NRTTitlePlotViewVectorCA];
    float xTrans = [[plotViewVector objectAtIndex:0] floatValue];
    float yTrans = [[plotViewVector objectAtIndex:1] floatValue];
    [titleTrans translateXBy:xTrans yBy:yTrans];
    return [[[NRTPlotViewAnnotation alloc] initWithAttributedString:attribString
        andAffineTransform:titleTrans] autorelease];
}

@end
