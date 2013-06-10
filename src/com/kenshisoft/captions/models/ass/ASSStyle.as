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

package com.kenshisoft.captions.models.ass
{
	import com.kenshisoft.captions.models.IStyle;
	import com.kenshisoft.captions.models.STSStyle;
	
	public class ASSStyle extends STSStyle implements IStyle
	{
		private var _name:String = "Default";
		private var _fontEmbed:Boolean = false; // whether or not to use embedded fonts
		private var _orgFontSize:Number = 18;
		
		public function ASSStyle()
		{
			super();
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get fontEmbed():Boolean
		{
			return _fontEmbed;
		}
		
		public function set fontEmbed(value:Boolean):void
		{
			_fontEmbed = value;
		}
		
		public function get orgFontSize():Number
		{
			return _orgFontSize;
		}
		
		public function set orgFontSize(value:Number):void
		{
			_orgFontSize = value;
		}
		
		public function copy():IStyle
		{
			var newStyle:ASSStyle = new ASSStyle();
			newStyle.name = _name;
			newStyle.fontEmbed = _fontEmbed;
			newStyle.orgFontSize = _orgFontSize;
			
			// -----------------------------------------------
			
			newStyle.fontName = fontName;
			newStyle.fontSize = fontSize;
			
			newStyle.colours = new Vector.<uint>;
			for (var i:int; i < colours.length; i++)
				newStyle.colours.push(colours[i]);
			
			newStyle.fontWeight = fontWeight;
			newStyle.italic = italic;
			newStyle.underline = underline;
			newStyle.strikeOut = strikeOut;
			newStyle.fontScaleX = fontScaleX;
			newStyle.fontScaleY = fontScaleY
			newStyle.fontSpacing = fontSpacing;
			newStyle.fontAngleZ = fontAngleZ;
			newStyle.borderStyle = borderStyle;
			newStyle.outlineWidthX = outlineWidthX;
			newStyle.outlineWidthY = outlineWidthY;
			newStyle.shadowDepthX = shadowDepthX;
			newStyle.shadowDepthY = shadowDepthY;
			newStyle.alignment = alignment;
			newStyle.marginRect = marginRect.copy();
			newStyle.charSet = charSet;
			newStyle.relativeTo = relativeTo;
			newStyle.fontAngleX = fontAngleX;
			newStyle.fontAngleY = fontAngleY;
			newStyle.fontShiftX = fontShiftX;
			newStyle.fontShiftY = fontShiftY;
			newStyle.blur = blur;
			newStyle.gaussianBlur = gaussianBlur;
			
			return newStyle;
		}
	}
}
