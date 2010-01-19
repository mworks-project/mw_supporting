//
//  NRTPlotViewAnnotation.m
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

#import "NRTPlotViewAnnotation.h"
#import "NRTPlotView.h"


@implementation NRTPlotViewAnnotation


-(void)dealloc
{
    [_identifier release];
    [super dealloc];
}


-(NSObject <NSCopying> *)identifier
{
    return _identifier;
}


-(void)setIdentifier:(NSObject <NSCopying> *)identifier
{
    [_identifier autorelease];
    _identifier = [identifier copy];
}


// Draw relative to the plot view origin
-(void)drawInPlotView:(NRTPlotView *)view
{
    [super drawInPlotView:view atPoint:NSMakePoint(0.0, 0.0)];
}


@end
