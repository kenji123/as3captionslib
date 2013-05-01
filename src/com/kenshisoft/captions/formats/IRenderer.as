package com.kenshisoft.captions.formats
{
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	
	import com.kenshisoft.captions.FontClass;
	import com.kenshisoft.captions.models.IEvent;
	import com.kenshisoft.captions.models.ISubtitle;
	
	/**
	 * ...
	 * @author 
	 */
	public interface IRenderer
	{
		function render(subtitle:ISubtitle, event:IEvent, videoRect:Rectangle, container:DisplayObjectContainer, fontClasses:Vector.<FontClass>, time:Number = -1, animate:Boolean = true):ICaption
		function add(caption:ICaption, captionsOnDisplay:Vector.<ICaption>, container:DisplayObjectContainer):void
		function remove(caption:ICaption, container:DisplayObjectContainer):void
		
		function get parser():IParser;
	}
}
