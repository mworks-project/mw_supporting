//
//  NRTPlotObject.m
//  Narrative
//
//  Created by Drew McCormack on Tue Sep 03 2002.
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

#import "NRTPlotObject.h"

static NSDictionary *_defaultAttributesDict;

// String constants for attributes
NSString *NRTLineWidthAttrib 		= @"NRTLineWidthAttrib";
NSString *NRTLineColorAttrib 		= @"NRTLineColorAttrib";
NSString *NRTFillColorAttrib 		= @"NRTFillColorAttrib";


@implementation NRTPlotObject

+(void)initialize 
{
    _defaultAttributesDict = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSNumber numberWithFloat:1.5],		NRTLineWidthAttrib,
        [NSColor blackColor],			NRTLineColorAttrib,
        [NSColor blackColor],			NRTFillColorAttrib,
        nil];
}

-(id)init {
    if ( self = [super init] )
    {
        [self setAttributesDictionary:[_defaultAttributesDict mutableCopy]];
    }
    return self;
}

-(void)dealloc
{
    [_attributesDictionary release];
    [super dealloc];
}

+(NSDictionary *)defaultAttributesDictionary {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
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

-(void)setAttribute:(id)obj forKey:(NSObject <NSCopying> *)key
{
    NSAssert( (key != nil) && (obj != nil), @"Attempt to set an attribute in NRTPlotObject with a nil value" );
    [_attributesDictionary setObject:obj forKey:key];
}

-(id)attributeForKey:(NSObject <NSCopying> *)key {
    return [_attributesDictionary objectForKey:key];
}

@end
