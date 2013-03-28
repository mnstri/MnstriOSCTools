//
//  AnimataOSCJointPlugIn.h
//  AnimataOSCJoint
//
//  Created by Matti Niinimäki on 7/10/09.
//  Check the readme for license
//

#import <Quartz/Quartz.h>
#import <VVOSC/VVOSC.h>

@interface AnimataOSCJointPlugIn : QCPlugIn
{
	OSCManager				*manager;
    OSCOutPort				*outport;
}

@property(assign) NSString*		inputIP;
@property(assign) NSUInteger	inputPort;

@property(assign) NSString*		inputJointName;

@property(assign) BOOL			inputJointSendPosition;
@property(assign) double		inputJointXPosition;
@property(assign) double		inputJointYPosition;

/*
Declare here the Obj-C 2.0 properties to be used as input and output ports for the plug-in e.g.
@property double inputFoo;
@property(assign) NSString* outputBar;
You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
*/

@end
