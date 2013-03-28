//
//  AnimataOSCPlugIn.h
//  AnimataOSC
//
//  Created by Matti Niinimäki on 7/9/09.
//  Check the readme for license
//

#import <Quartz/Quartz.h>
#import <VVOSC/VVOSC.h>

@interface AnimataOSCPlugIn : QCPlugIn
{
	OSCManager				*manager;
    OSCOutPort				*outport;
}

@property(assign) NSString*		inputIP;
@property(assign) NSUInteger	inputPort;

@property(assign) NSString*		inputLayerName;

@property(assign) BOOL			inputLayerSendOpacity;
@property(assign) double		inputLayerOpacity;

@property(assign) BOOL			inputLayerSendVisibility;
@property(assign) BOOL			inputLayerVisibility;

@property(assign) BOOL			inputLayerSendPosition;
@property(assign) double		inputLayerXPosition;
@property(assign) double		inputLayerYPosition;
@property(assign) double		inputLayerZPosition;

@property(assign) BOOL			inputLayerSendDelta;
@property(assign) double		inputLayerXDelta;
@property(assign) double		inputLayerYDelta;
//@property(assign) double		inputLayerZDelta;



/*
Declare here the Obj-C 2.0 properties to be used as input and output ports for the plug-in e.g.
@property double inputFoo;
@property(assign) NSString* outputBar;
You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
*/

@end
