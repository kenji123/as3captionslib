package com.kenshisoft.captions.formats
{
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import com.kenshisoft.captions.FontClass;
	import com.kenshisoft.captions.models.IEvent;
	import com.kenshisoft.captions.models.IStyle;
	import com.kenshisoft.captions.models.ISubtitle;
	
	/**
	 * ...
	 * @author 
	 */
	public interface IRenderer
	{
		//function renderText(text:String, style_:IStyle, outline:Boolean = false, bodyShadow:Boolean = false, outlineShadow:Boolean = false):*
		function render(subtitle_:ISubtitle, event_:IEvent, videoRect:Rectangle, container:DisplayObjectContainer, time:Number = -1, animate:Boolean = true, caption_:ICaption = null):ICaption
		function add(caption_:ICaption, captionsOnDisplay_:Vector.<ICaption>, container:DisplayObjectContainer, rerender:Boolean = false):void
		function remove(caption_:ICaption, container:DisplayObjectContainer):void
		
		function get parser():IParser;
	}
}
