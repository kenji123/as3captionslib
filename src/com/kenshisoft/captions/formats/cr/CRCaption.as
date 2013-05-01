package com.kenshisoft.captions.formats.cr
{
	import flash.display.Sprite;
	
	import com.kenshisoft.captions.formats.ICaption;
	import com.kenshisoft.captions.models.cr.CREvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class CRCaption implements ICaption
	{
		public var event:CREvent;
		
		private var _renderSprite:Sprite;
		
		public function CRCaption(event:CREvent)
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
