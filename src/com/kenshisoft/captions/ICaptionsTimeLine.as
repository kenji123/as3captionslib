package com.kenshisoft.captions
{
	import com.kenshisoft.captions.formats.ICaption;
	import flash.display.DisplayObjectContainer;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.NetStream;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author 
	 */
	public interface ICaptionsTimeLine
	{
		function get captionDisplaySignal():Signal;
		function get captionRemoveSignal():Signal;
		
		function start():void;
		function pause():void;
		function resume():void;
		function flushBuffer(time:Number = -1):void;
		
		function get animated():Boolean;
		function set animated(value:Boolean):void;
		function get timeShift():Number;
		function set timeShift(value:Number):void;
		
		function setContainer(container:DisplayObjectContainer):void;
		function setStream(stream:NetStream):void;
		function setVideoRect(videoRect:Rectangle):void;
	}
}
