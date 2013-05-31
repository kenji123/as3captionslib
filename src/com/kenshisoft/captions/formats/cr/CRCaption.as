//
// Copyright 2011-2013 Jamal Edey
// 
// This file is part of as3captionslib.
// 
// as3captionslib is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// as3captionslib is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with as3captionslib.  If not, see <http://www.gnu.org/licenses/>.
//

package com.kenshisoft.captions.formats.cr
{
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import com.kenshisoft.captions.formats.ICaption;
	import com.kenshisoft.captions.formats.ass.ASSAnimOptions;
	import com.kenshisoft.captions.models.cr.CREvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class CRCaption implements ICaption
	{
		public var wrapStyle:int;
		public var alignment:int;
		public var event:CREvent;
		
		private var _orgWrapStyle:int;
		private var _animOptions:ASSAnimOptions;
		private var _textField:TextField;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _effects:Object = new Object();
		private var _renderSprite:Sprite;
		
		public function CRCaption(wrapStyle:int, alignment:int, event:CREvent)
		{
			super();
			
			this.wrapStyle = _orgWrapStyle = wrapStyle;
			this.alignment = -alignment;
			this.event = event;
			
			effects.COUNT = 0;
		}
		
		public function get orgWrapStyle():int
		{
			return _orgWrapStyle;
		}
		
		public function get animOptions():ASSAnimOptions
		{
			return _animOptions;
		}
		
		public function set animOptions(value:ASSAnimOptions):void
		{
			_animOptions = value;
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
		
		public function get effects():Object
		{
			return _effects;
		}
		
		public function set effects(value:Object):void
		{
			_effects = value;
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
