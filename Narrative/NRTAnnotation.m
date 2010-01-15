//
//  NRTAnnotation.m
//  Narrative
//
//  Created by Drew A. McCormack on Mon Sep 02 2002.
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

#import "NRTAnnotation.h"


@implementation NRTAnnotation


+(id)annotationWithAttributedString:(NSAttributedString *)string andAffineTransform:(NSAffineTransform *)transform
{
    return [[[NRTAnnotation alloc] initWithAttributedString:string andAffineTransform:transform] autorelease];
}

+(id)annotationWithAttributedString:(NSAttributedString *)string
{
    return [self annotationWithAttributedString:string andAffineTransform:[NSAffineTransform transform]];
}

// Designated constructor.
-(id)initWithAttributedString:(NSAttributedString *)string andAffineTransform:(NSAffineTransform *)transform 
{
    if ( self = [super init] ) 
    {
        [self setAffineTransform:transform];
        [self setAttributedString:string];
    }
    return self;
}


-(id)initWithAttributedString:(NSAttributedString *)string 
{
    return [self initWithAttributedString:string andAffineTransform:[NSAffineTransform transform]];
}


-(void)dealloc
{
    [_affineTransform release];
    [_attributedString release];
    [super dealloc];
}


-(void)drawInPlotView:(NRTPlotView *)view atPoint:(NSPoint)point
{
    NSAffineTransform *trans = [NSAffineTransform transform];
    NSAffineTransform *myTrans = [self affineTransform];
    
    // NRTTransform origin to point, then apply transform
    [trans translateXBy:point.x yBy:point.y];
    [trans prependTransform:myTrans];

    [trans concat];
    [[self attributedString] drawAtPoint:NSMakePoint([[self attributedString] size].width * -0.5, [[self attributedString] size].height * -0.5 )];
    [trans invert];
    [trans concat];
}


-(NSAffineTransform *)affineTransform {
    return _affineTransform;
}


-(void)setAffineTransform:(NSAffineTransform *)transform
{
    [_affineTransform autorelease];
    _affineTransform = [transform retain];
}


-(NSAttributedString *)attributedString {
    return _attributedString;
}


-(void)setAttributedString:(NSAttributedString *)string
{
    [_attributedString autorelease];
    _attributedString = [string copy];
}


@end
