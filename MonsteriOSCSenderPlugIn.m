//
//  MonsteriOSCSenderPlugIn.m
//  MonsteriOSCSender
//
//  Created by Matti Niinimäki on 7/15/09.
//  Check the readme for license
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "MonsteriOSCSenderPlugIn.h"

#define	kQCPlugIn_Name				@"Mnstri OSC Sender"
#define	kQCPlugIn_Description		@"OSC sender patch that allows you to dynamically change the IP and port numbers. Still missing the ability to send structures. MnstriOSCTools 1.5. http://mansteri.com"

@implementation MonsteriOSCSenderPlugIn

/*
 Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
 @dynamic inputFoo, outputBar;
 */

@dynamic /*inputStructure, */inputBoolean, inputString, inputIndex, inputFloat, inputSendOSC, inputSelectType, inputNameSpace, inputPort, inputIP;

+ (NSDictionary*) attributes
{
	/*
	 Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
	 */
	
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/*
	 Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
	 */
	
	if([key isEqualToString:@"inputIP"])
		
        return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"IP Address", QCPortAttributeNameKey,
				
				@"127.0.0.1",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	
	if([key isEqualToString:@"inputPort"])
		
        return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Port Number", QCPortAttributeNameKey,
				
				[NSNumber numberWithUnsignedInteger:1234],  QCPortAttributeDefaultValueKey,
				
				nil];
	
	
	if([key isEqualToString:@"inputNameSpace"])
		
        return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Address Space", QCPortAttributeNameKey,
				
				@"/qc",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputSelectType"])
		
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Select Data Type", QCPortAttributeNameKey,
				
				[NSNumber numberWithUnsignedInteger:0],  QCPortAttributeMinimumValueKey,
				
				[NSNumber numberWithUnsignedInteger:0],  QCPortAttributeDefaultValueKey,
				
				[NSNumber numberWithUnsignedInteger:4], QCPortAttributeMaximumValueKey, 
				
				[NSArray arrayWithObjects:@"Float", @"Index", @"String", @"Boolean",nil], QCPortAttributeMenuItemsKey, 
				
				nil];
	
	
	if([key isEqualToString:@"inputSendOSC"])
		
        return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Send", QCPortAttributeNameKey,
				
				@"1",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	
	if([key isEqualToString:@"inputFloat"])
		
        return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Float", QCPortAttributeNameKey,
				
				[NSNumber numberWithFloat:0],  QCPortAttributeDefaultValueKey,
				
				nil];
	
	
	if([key isEqualToString:@"inputIndex"])
		
        return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Index", QCPortAttributeNameKey,
				
				@"0",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	
	if([key isEqualToString:@"inputString"])
		
        return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"String", QCPortAttributeNameKey,
				
				@"",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	
	if([key isEqualToString:@"inputBoolean"])
		
        return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Boolean", QCPortAttributeNameKey,
				
				@"0",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	
	return nil;
}

+ (QCPlugInExecutionMode) executionMode
{
	/*
	 Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	 */
	
	return kQCPlugInExecutionModeConsumer;
}

+ (QCPlugInTimeMode) timeMode
{
	/*
	 Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	 */
	
	return kQCPlugInTimeModeTimeBase;
}

- (id) init
{
	if(self = [super init]) {
		/*
		 Allocate any permanent resource required by the plug-in.
		 */
		manager = [[OSCManager alloc] init];
	}
	
	return self;
}

- (void) finalize
{
	/*
	 Release any non garbage collected resources created in -init.
	 */
	
	[super finalize];
}

- (void) dealloc
{
	/*
	 Release any resources created in -init.
	 */
	
	[super dealloc];
}

@end

@implementation MonsteriOSCSenderPlugIn (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
	/*
	 Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	 Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	 */
	
	outport = [manager createNewOutputToAddress:@"127.0.0.1" atPort:12345 withLabel:@"qc OSC plugin"];
	
	return YES;
}

- (void) enableExecution:(id<QCPlugInContext>)context
{
	/*
	 Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
	 */
}

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{
	/*
	 Called by Quartz Composer whenever the plug-in instance needs to execute.
	 Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	 Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	 
	 The OpenGL context for rendering can be accessed and defined for CGL macros using:
	 CGLContextObj cgl_ctx = [context CGLContextObj];
	 */
	
	OSCMessage		*msg = nil;
    OSCPacket		*packet = nil;
	
	//There was a bug in QC that prevented "didValueForInputKeyChange" from working if inside iterator
    //need to check if that still happens
    
	//if([self didValueForInputKeyChange:@"inputIP"]){
		[outport setAddressString:self.inputIP];
	//}
	
	//if([self didValueForInputKeyChange:@"inputPort"]){
		[outport setPort:self.inputPort];
	//}
	
	if(self.inputSendOSC /*&& [self didValueForInputKeyChange:@"inputSendOSC"]*/){
		switch (self.inputSelectType) {
			case 0:
				msg = [OSCMessage createWithAddress:self.inputNameSpace];
				[msg addFloat:self.inputFloat];
				packet = [OSCPacket createWithContent:msg];
				[outport sendThisPacket: packet];
				break;
			case 1:
				msg = [OSCMessage createWithAddress:self.inputNameSpace];
				[msg addInt:self.inputIndex];
				packet = [OSCPacket createWithContent:msg];
				[outport sendThisPacket: packet];
				break;
			case 2:
				msg = [OSCMessage createWithAddress:self.inputNameSpace];
				[msg addString:self.inputString];
				packet = [OSCPacket createWithContent:msg];
				[outport sendThisPacket: packet];
				break;
			case 3:
				msg = [OSCMessage createWithAddress:self.inputNameSpace];
				[msg addBOOL:self.inputBoolean];
				packet = [OSCPacket createWithContent:msg];
				[outport sendThisPacket: packet];
				break;
				// Structures
				/*
				 case 4:
				 msg = [OSCMessage createWithAddress:self.inputNameSpace];
				 packet = [OSCPacket createWithContent:msg];
				 [outport sendThisPacket: packet];
				 break;
				 */
			default:
				break;
		}
	}
	
	return YES;
}

- (void) disableExecution:(id<QCPlugInContext>)context
{
	/*
	 Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	 */
}

- (void) stopExecution:(id<QCPlugInContext>)context
{
	/*
	 Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	 */
	[manager removeOutput:outport];
}

@end
