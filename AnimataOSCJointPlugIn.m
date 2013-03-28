//
//  AnimataOSCJointPlugIn.m
//  AnimataOSCJoint
//
//  Created by Matti Niinimäki on 7/10/09.
//  Check the readme for license
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "AnimataOSCJointPlugIn.h"

#define	kQCPlugIn_Name				@"Animata Joint OSC"
#define	kQCPlugIn_Description		@"Sends Animata compatible OSC messages. Controls the different joint parameters. MnstriOSCTools 1.0"

@implementation AnimataOSCJointPlugIn

@dynamic inputJointYPosition, inputJointXPosition, inputJointSendPosition, inputJointName, inputPort, inputIP;

/*
Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
@dynamic inputFoo, outputBar;
*/

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
				
				[NSNumber numberWithUnsignedInteger:7110],  QCPortAttributeDefaultValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputJointName"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Joint Name", QCPortAttributeNameKey,
				
				@"",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputJointSendPosition"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Send Joint Position", QCPortAttributeNameKey,
				
				@"1",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputJointXPosition"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Joint X Position", QCPortAttributeNameKey,
				
				@"0",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputJointYPosition"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Joint Y Position", QCPortAttributeNameKey,
				
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
	
	return kQCPlugInTimeModeNone;
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

+ (NSArray*) plugInKeys
{
	/*
	Return a list of the KVC keys corresponding to the internal settings of the plug-in.
	*/
	
	return nil;
}

- (id) serializedValueForKey:(NSString*)key;
{
	/*
	Provide custom serialization for the plug-in internal settings that are not values complying to the <NSCoding> protocol.
	The return object must be nil or a PList compatible i.e. NSString, NSNumber, NSDate, NSData, NSArray or NSDictionary.
	*/
	
	return [super serializedValueForKey:key];
}

- (void) setSerializedValue:(id)serializedValue forKey:(NSString*)key
{
	/*
	Provide deserialization for the plug-in internal settings that were custom serialized in -serializedValueForKey.
	Deserialize the value, then call [self setValue:value forKey:key] to set the corresponding internal setting of the plug-in instance to that deserialized value.
	*/
	
	[super setSerializedValue:serializedValue forKey:key];
}

- (QCPlugInViewController*) createViewController
{
	/*
	Return a new QCPlugInViewController to edit the internal settings of this plug-in instance.
	You can return a subclass of QCPlugInViewController if necessary.
	*/
	
	return [[QCPlugInViewController alloc] initWithPlugIn:self viewNibName:@"Settings"];
}

@end

@implementation AnimataOSCJointPlugIn (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	*/
	
	outport = [manager createNewOutputToAddress:@"127.0.0.1" atPort:7110 withLabel:@"qc animata plugin"];
	
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
	
	OSCMessage				*msg = nil;
    OSCPacket				*packet = nil;
	NSString*				OSCIP = @"127.0.0.1";
	NSUInteger				OSCPort = 7110;
	NSString*				jointName = @"";
	double					xJointPosition = 0;
	double					yJointPosition = 0;
	
	OSCIP = self.inputIP;
	OSCPort = self.inputPort;
	jointName = self.inputJointName;
	xJointPosition = self.inputJointXPosition;
	yJointPosition = self.inputJointYPosition;
	
	
	if([self didValueForInputKeyChange:@"inputIP"]){
		[outport setAddressString:OSCIP];
	}
	
	if([self didValueForInputKeyChange:@"inputPort"]){
		[outport setPort:OSCPort];
	}
	
	if(self.inputJointSendPosition){
			msg = [OSCMessage createWithAddress:@"/joint"];
			[msg addString:jointName];
			[msg addFloat:xJointPosition];
			[msg addFloat:yJointPosition];
			packet = [OSCPacket createWithContent:msg];
			[outport sendThisPacket: packet];
		
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
	//Close the port when rendering stops
	[manager removeOutput:outport];
}

@end
