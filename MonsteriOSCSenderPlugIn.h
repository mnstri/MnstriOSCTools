//
//  MonsteriOSCSenderPlugIn.h
//  MonsteriOSCSender
//
//  Created by Matti Niinimäki on 7/15/09.
//  Check the readme for license
//

#import <Quartz/Quartz.h>
#import <VVOSC/VVOSC.h>

@interface MonsteriOSCSenderPlugIn : QCPlugIn
{
	OSCManager				*manager;
    OSCOutPort				*outport;
}

/*
 Declare here the Obj-C 2.0 properties to be used as input and output ports for the plug-in e.g.
 @property double inputFoo;
 @property(assign) NSString* outputBar;
 You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
 */

@property(assign) NSString*			inputIP;
@property(assign) NSUInteger		inputPort;
@property(assign) NSString*			inputNameSpace;
@property(assign) BOOL				inputSendOSC;
@property(assign) NSUInteger		inputSelectType;
@property(assign) double			inputFloat;
@property(assign) NSUInteger		inputIndex;
@property(assign) NSString*			inputString;
@property(assign) BOOL				inputBoolean;
//@property(assign) NSDictionary *	inputStructure;

@end
