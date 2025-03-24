package blok.bridge.macro;

import blok.bridge.Constants;
import haxe.macro.*;

function getDotBridgeDirectory() {
	#if !macro
	return Compiler.getDefine('blok.bridge.dot-bridge') ?? DotBridge;
	#else
	return Context.definedValue('blok.bridge.dot-bridge') ?? DotBridge;
	#end
}

function getIslandsMainName() {
	#if !macro
	return Compiler.getDefine('blok.bridge.islands-main') ?? IslandsMain;
	#else
	return Context.definedValue('blok.bridge.islands-main') ?? IslandsMain;
	#end
}
