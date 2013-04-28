package com.kenshisoft.captions.formats.cr
{
	import flash.display.Sprite;
	
	import com.kenshisoft.captions.formats.ICaption;
	
	/**
	 * ...
	 * @author 
	 */
	public class CRCaption implements ICaption
	{
		private var _renderSprite:Sprite;
		
		public function CRCaption()
		{
			
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
