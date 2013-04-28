package com.kenshisoft.captions.formats
{
	import com.kenshisoft.captions.FontClass;
	import com.kenshisoft.captions.models.IEvent;
	import com.kenshisoft.captions.models.ISubtitle;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author 
	 */
	public interface IRenderer
	{
		function get parser():IParser;
		
		function render(subtitle:ISubtitle, event:IEvent, videoRect:Rectangle, container:DisplayObjectContainer, captionsOnDisplay:Vector.<ICaption>, fontClasses:Vector.<FontClass>, time:Number = -1, animate:Boolean = true):ICaption
	}
}
