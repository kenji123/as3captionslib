package com.kenshisoft.captions.formats.cr
{
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import com.kenshisoft.captions.formats.ICaption;
	import com.kenshisoft.captions.models.cr.CREvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class CRCaption implements ICaption
	{
		public var alignment:int;
		public var event:CREvent;
		
		private var _textField:TextField;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _renderSprite:Sprite;
		
		public function CRCaption(alignment:int, event:CREvent)
		{
			super();
			
			this.alignment = -alignment;
			this.event = event;
		}
		
		public function get textField():TextField
		{
			return _textField;
		}
		
		public function set textField(value:TextField):void
		{
			_textField = value;
		}
		
		public function get scaleX():Number
		{
			return _scaleX;
		}
		
		public function set scaleX(value:Number):void
		{
			_scaleX = value;
		}
		
		public function get scaleY():Number
		{
			return _scaleY;
		}
		
		public function set scaleY(value:Number):void
		{
			_scaleY = value;
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
