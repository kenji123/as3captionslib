package com.kenshisoft.captions.formats.srt
{
	import com.kenshisoft.captions.formats.ICaption;
	import com.kenshisoft.captions.models.srt.SRTEvent;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author 
	 */
	public class SRTCaption implements ICaption
	{
		public var event:SRTEvent;
		
		private var _renderSprite:Sprite;
		
		public function SRTCaption(event:SRTEvent)
		{
			super();
			
			this.event = event;
		}
		
		public function get renderSprite():Sprite
		{
			return _renderSprite;
		}
		
		public function set renderSprite(value:Sprite):void
		{
			_renderSprite = value;
		}
	}
}
