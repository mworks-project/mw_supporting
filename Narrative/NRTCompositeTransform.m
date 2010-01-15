//
//  NRTCompositeTransform.m
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

#import "NRTCompositeTransform.h"


@implementation NRTCompositeTransform

-(id)initWithSubTransforms:(NSArray *)subTransforms 
{
    if ( self = [super init] ) 
    {
        [self setSubTransforms:subTransforms];
    }
    return self;
}

-(void)dealloc 
{
    [_subTransforms release];
    [super dealloc];
}

-(void)setSubTransforms:(NSArray *)subTransforms 
{
    [_subTransforms autorelease];
    _subTransforms = [subTransforms retain];
}

-(NSArray *)subTransforms 
{
    return _subTransforms;
}

@end
