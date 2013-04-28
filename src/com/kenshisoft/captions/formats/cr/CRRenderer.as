package com.kenshisoft.captions.formats.cr
{
	import com.kenshisoft.captions.FontClass;
	import com.kenshisoft.captions.formats.ICaption;
	import com.kenshisoft.captions.formats.IParser;
	import com.kenshisoft.captions.formats.IRenderer;
	import com.kenshisoft.captions.models.cr.CREvent;
	import com.kenshisoft.captions.models.cr.CRSubtitleScript;
	import com.kenshisoft.captions.models.IEvent;
	import com.kenshisoft.captions.models.ISubtitle;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author 
	 */
	public class CRRenderer implements IRenderer
	{
		private var _parser:CRParser;
		public function get parser():IParser { return _parser; }
		
		public function CRRenderer()
		{
			super();
			
			_parser = new CRParser();
		}
		
		public function render(subtitle:ISubtitle, event:IEvent, videoRect:Rectangle, container:DisplayObjectContainer, captionsOnDisplay:Vector.<ICaption>, fontClasses:Vector.<FontClass>, time:Number = -1, animate:Boolean = true):ICaption
		{
			return new CRCaption();
		}
	}
}
