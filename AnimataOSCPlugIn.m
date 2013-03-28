//
//  AnimataOSCPlugIn.m
//  AnimataOSC
//
//  Created by Matti Niinimäki on 7/9/09.
//  Check the readme for license
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "AnimataOSCPlugIn.h"

#define	kQCPlugIn_Name				@"Animata Layer OSC"
#define	kQCPlugIn_Description		@"Sends Animata compatible OSC messages. Controls the different layer parameters. MnstriOSCTools 1.0"

@implementation AnimataOSCPlugIn

@dynamic inputLayerOpacity, inputLayerSendOpacity, inputLayerVisibility, inputLayerSendVisibility, /*inputLayerZDelta, */inputLayerYDelta, inputLayerXDelta, inputLayerSendDelta, inputLayerZPosition, inputLayerYPosition, inputLayerXPosition, inputLayerSendPosition, inputLayerName, inputPort, inputIP;

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
	
	if([key isEqualToString:@"inputLayerName"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Layer Name", QCPortAttributeNameKey,
				
				@"",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputLayerOpacity"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Layer Opacity", QCPortAttributeNameKey,
				
				[NSNumber numberWithFloat:1],  QCPortAttributeDefaultValueKey,
				
				[NSNumber numberWithFloat:1],  QCPortAttributeMaximumValueKey,
				
				[NSNumber numberWithFloat:0],  QCPortAttributeMinimumValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputLayerVisibility"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Layer Visibility", QCPortAttributeNameKey,
				
				@"1",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputLayerSendOpacity"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Send Opacity", QCPortAttributeNameKey,
				
				@"1",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputLayerSendVisibility"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Send Visibility", QCPortAttributeNameKey,
				
				@"1",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputLayerSendPosition"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Send Absolute Position", QCPortAttributeNameKey,
				
				@"1",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputLayerXPosition"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Layer X Absolute Position", QCPortAttributeNameKey,
				
				@"0",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputLayerYPosition"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Layer Y Absolute Position", QCPortAttributeNameKey,
				
				@"0",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputLayerZPosition"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Layer Z Absolute Position", QCPortAttributeNameKey,
				
				@"0",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputLayerSendDelta"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Send Relative Position", QCPortAttributeNameKey,
				
				0,  QCPortAttributeDefaultValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputLayerXDelta"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Layer X Relative Position", QCPortAttributeNameKey,
				
				@"0",  QCPortAttributeDefaultValueKey,
				
				nil];
	
	if([key isEqualToString:@"inputLayerYDelta"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Layer Y Relative Position", QCPortAttributeNameKey,
				
				@"0",  QCPortAttributeDefaultValueKey,
				
				nil];
	/*
	if([key isEqualToString:@"inputLayerZDelta"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				
				@"Layer Z Relative Position", QCPortAttributeNameKey,
				
				@"0",  QCPortAttributeDefaultValueKey,
				
				nil];
	 */
	
	
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

@implementation AnimataOSCPlugIn (Execution)

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
	NSString*				layerName = @"";
	double					opacity = 1.0;
	BOOL					visibility = YES;
	double					xPosition = 0;
	double					yPosition = 0;
	double					zPosition = 0;
	double					xDelta = 0;
	double					yDelta = 0;
	//double					zDelta = 0;
	
	
	OSCIP = self.inputIP;
	OSCPort = self.inputPort;
	layerName = self.inputLayerName;
	opacity = self.inputLayerOpacity;
	visibility = self.inputLayerVisibility;
	xPosition = self.inputLayerXPosition;
	yPosition = self.inputLayerYPosition;
	zPosition = self.inputLayerZPosition;
	xDelta = self.inputLayerXDelta;
	yDelta = self.inputLayerYDelta;
	//zDelta = self.inputLayerZDelta;

	
	if([self didValueForInputKeyChange:@"inputIP"]){
		[outport setAddressString:OSCIP];
	}
	
	if([self didValueForInputKeyChange:@"inputPort"]){
		[outport setPort:OSCPort];
	}
	
	if(self.inputLayerSendVisibility && [self didValueForInputKeyChange:@"inputLayerVisibility"]){
		msg = [OSCMessage createWithAddress:@"/layervis"];
		[msg addString:layerName];
		[msg addBOOL:visibility];
		packet = [OSCPacket createWithContent:msg];
		[outport sendThisPacket: packet];
	}
	
	if(self.inputLayerSendOpacity){
		msg = [OSCMessage createWithAddress:@"/layeralpha"];
		[msg addString:layerName];
		[msg addFloat:opacity];
		packet = [OSCPacket createWithContent:msg];
		[outport sendThisPacket: packet];
	}
	
	if(self.inputLayerSendPosition){
		msg = [OSCMessage createWithAddress:@"/layerpos"];
		[msg addString:layerName];
		[msg addFloat:xPosition];
		[msg addFloat:yPosition];
		[msg addFloat:zPosition];
		packet = [OSCPacket createWithContent:msg];
		[outport sendThisPacket: packet];
	}
	
	if(self.inputLayerSendDelta){
		msg = [OSCMessage createWithAddress:@"/layerdeltapos"];
		[msg addString:layerName];
		[msg addFloat:xDelta];
		[msg addFloat:yDelta];
		//[msg addFloat:zDelta];
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
