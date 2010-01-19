//
//  NRTPlotView.m
//  Narrative
//
//  Created by Drew McCormack on Sat Aug 10 2002.
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

#import "NRTPlotView.h"
#import "NRTPlotViewComponent.h"


@implementation NRTPlotView

- (id)initWithFrame:(NSRect)frame 
{
    if ( self = [super initWithFrame:frame] ) 
    {
        [self setBackgroundColor:nil];
        [self setComponentArray:[NSMutableArray array]];
        [self setUseImageCache:YES];
        [self setNeedsLayout:YES];
    }
    return self;
}

-(void)dealloc
{
    [_backgroundColor release];
    [_componentArray release];
    [super dealloc];
}

-(void)setUseImageCache:(BOOL)useCache {
    _useImageCache = useCache;
}

-(BOOL)useImageCache {
    return _useImageCache;
}

-(void)setNeedsLayout:(BOOL)needsLayout 
{
    _needsLayout = needsLayout;
}

-(BOOL)needsLayout
{
    return _needsLayout;
}

// Default is to do nothing, but reset the layout flag.
-(void)layout {
    [self setNeedsLayout:NO];
}

- (void)drawRect:(NSRect)rect 
{
    BOOL drawingInCache = NO;
    
    if ( [self useImageCache] && [self needsLayout] ) {
        drawingInCache = YES;
        [_cachedImage release];
        _cachedImage = [[NSImage alloc] initWithSize:[self frame].size];
        [_cachedImage lockFocus];
    }
 
    // Layout and draw.
    if ( ![self useImageCache] || drawingInCache ) {
        if ( [self needsLayout] ) [self layout];
        
        NSEnumerator *plotEnum = [[self componentArray] objectEnumerator];
        NSObject <NRTPlotViewComponent> * component;
        
        // Draw background
        if ( [self backgroundColor] ) 
        {
            [[self backgroundColor] set];
            [NSBezierPath fillRect:[self bounds]];
        }
                        
        // Draw components in order
        while ( plotEnum && ( component = [plotEnum nextObject] ) ) 
        {
            [component drawInPlotView:self];
        }
        
    }
    
    // Unlock focus if necessary.
    if ( drawingInCache ) {
        [_cachedImage unlockFocus];
    }
    
    // If we are caching, we need to copy to screen.
    if ( [self useImageCache] ) {
        [_cachedImage compositeToPoint:rect.origin fromRect:rect operation:NSCompositeSourceOver];
    }
        
}

-(BOOL)isOpaque {
    return ( [[self backgroundColor] alphaComponent] == 1.0 );
}

-(void)addComponent:(NSObject <NRTPlotViewComponent> *)component
{
    NSAssert( nil != [self componentArray], @"Component array was nil in addComponent:" );
    NSAssert( nil != component, @"Component was nil in addComponent:" );
    [[self componentArray] addObject:component];
    [self setNeedsDisplay:YES];
}
    
-(void)removeAllComponents 
{
    NSAssert( nil != [self componentArray], @"Component array was nil in removeComponent" );
    [[self componentArray] removeAllObjects];
    [self setNeedsDisplay:YES];
}

-(void)setComponentArray:(NSMutableArray *)dict 
{
    id old = _componentArray;
    _componentArray = [dict retain];
    [old release];
}

-(NSMutableArray *)componentArray 
{
    return _componentArray;
}

-(void)setBackgroundColor:(NSColor *)color
{
    [color retain];
    [_backgroundColor release];
    _backgroundColor = color;
}

-(NSColor *)backgroundColor
{
    return _backgroundColor;
}

@end
