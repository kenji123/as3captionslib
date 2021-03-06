﻿//
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

package com.kenshisoft.captions.models
{
	import com.kenshisoft.captions.misc.MarginRectangle;

	public class STSStyle
	{
		private var _fontName:String = "Arial";
		private var _fontSize:Number = 18;
		private var _colours:Vector.<uint> = new Vector.<uint>; // primary, secondary, outline, back
		private var _fontWeight:String = "bold";
		private var _italic:String = "normal";
		private var _underline:String = "none";
		private var _strikeOut:Boolean = false;
		private var _fontScaleX:Number = 100;
		private var _fontScaleY:Number = 100;
		private var _fontSpacing:Number = 0;
		private var _fontAngleZ:Number = 0;
		private var _borderStyle:int = 0;
		private var _outlineWidthX:Number = 2;
		private var _outlineWidthY:Number = 2;
		private var _shadowDepthX:Number = 3;
		private var _shadowDepthY:Number = 3;
		private var _alignment:int = 2;
		private var _marginRect:MarginRectangle = new MarginRectangle(20, 20, 20, 20);
		private var _charSet:int = 1; //TODO: charset/locale
		private var _relativeTo:int = 1; // 0: window, 1: video, 2: undefined (default: window)
		private var _fontAngleX:Number = 0;
		private var _fontAngleY:Number = 0;
		private var _fontShiftX:Number = 0;
		private var _fontShiftY:Number = 0;
		private var _blur:int = 0;
		private var _gaussianBlur:int = 0;
		
		public function STSStyle()
		{
			super();
			
			_colours.push(0x00ffffff, 0x0000ffff, 0x00000000, 0x80000000);
		}
		
		public function get fontName():String
		{
			return _fontName;
		}
		
		public function set fontName(value:String):void
		{
			_fontName = value;
		}
		
		public function get fontSize():Number
		{
			return _fontSize;
		}
		
		public function set fontSize(value:Number):void
		{
			_fontSize = value;
		}
		
		public function get colours():Vector.<uint>
		{
			return _colours;
		}
		
		public function set colours(value:Vector.<uint>):void
		{
			_colours = value;
		}
		
		public function get fontWeight():String
		{
			return _fontWeight;
		}
		
		public function set fontWeight(value:String):void
		{
			_fontWeight = value;
		}
		
		public function get italic():String
		{
			return _italic;
		}
		
		public function set italic(value:String):void
		{
			_italic = value;
		}
		
		public function get underline():String
		{
			return _underline;
		}
		
		public function set underline(value:String):void
		{
			_underline = value;
		}
		
		public function get strikeOut():Boolean
		{
			return _strikeOut;
		}
		
		public function set strikeOut(value:Boolean):void
		{
			_strikeOut = value;
		}
		
		public function get fontScaleX():Number
		{
			return _fontScaleX;
		}
		
		public function set fontScaleX(value:Number):void
		{
			_fontScaleX = value;
		}
		
		public function get fontScaleY():Number
		{
			return _fontScaleY;
		}
		
		public function set fontScaleY(value:Number):void
		{
			_fontScaleY = value;
		}
		
		public function get fontSpacing():Number
		{
			return _fontSpacing;
		}
		
		public function set fontSpacing(value:Number):void
		{
			_fontSpacing = value;
		}
		
		public function get fontAngleZ():Number
		{
			return _fontAngleZ;
		}
		
		public function set fontAngleZ(value:Number):void
		{
			_fontAngleZ = value;
		}
		
		public function get borderStyle():int
		{
			return _borderStyle;
		}
		
		public function set borderStyle(value:int):void
		{
			_borderStyle = value;
		}
		
		public function get outlineWidthX():Number
		{
			return _outlineWidthX;
		}
		
		public function set outlineWidthX(value:Number):void
		{
			_outlineWidthX = value;
		}
		
		public function get outlineWidthY():Number
		{
			return _outlineWidthY;
		}
		
		public function set outlineWidthY(value:Number):void
		{
			_outlineWidthY = value;
		}
		
		public function get shadowDepthX():Number
		{
			return _shadowDepthX;
		}
		
		public function set shadowDepthX(value:Number):void
		{
			_shadowDepthX = value;
		}
		
		public function get shadowDepthY():Number
		{
			return _shadowDepthY;
		}
		
		public function set shadowDepthY(value:Number):void
		{
			_shadowDepthY = value;
		}
		
		public function get alignment():int
		{
			return _alignment;
		}
		
		public function set alignment(value:int):void
		{
			_alignment = value;
		}
		
		public function get marginRect():MarginRectangle
		{
			return _marginRect;
		}
		
		public function set marginRect(value:MarginRectangle):void
		{
			_marginRect = value;
		}
		
		public function get charSet():int
		{
			return _charSet;
		}
		
		public function set charSet(value:int):void
		{
			_charSet = value;
		}
		
		public function get relativeTo():int
		{
			return _relativeTo;
		}
		
		public function set relativeTo(value:int):void
		{
			_relativeTo = value;
		}
		
		public function get fontAngleX():Number
		{
			return _fontAngleX;
		}
		
		public function set fontAngleX(value:Number):void
		{
			_fontAngleX = value;
		}
		
		public function get fontAngleY():Number
		{
			return _fontAngleY;
		}
		
		public function set fontAngleY(value:Number):void
		{
			_fontAngleY = value;
		}
		
		public function get fontShiftX():Number
		{
			return _fontShiftX;
		}
		
		public function set fontShiftX(value:Number):void
		{
			_fontShiftX = value;
		}
		
		public function get fontShiftY():Number
		{
			return _fontShiftY;
		}
		
		public function set fontShiftY(value:Number):void
		{
			_fontShiftY = value;
		}
		
		public function get blur():int
		{
			return _blur;
		}
		
		public function set blur(value:int):void
		{
			_blur = value;
		}
		
		public function get gaussianBlur():int
		{
			return _gaussianBlur;
		}
		
		public function set gaussianBlur(value:int):void
		{
			_gaussianBlur = value;
		}
	}
}
