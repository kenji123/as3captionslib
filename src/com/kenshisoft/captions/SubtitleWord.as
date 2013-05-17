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

package com.kenshisoft.captions
{
	import com.kenshisoft.captions.formats.ass.ASSRenderer;
	import com.kenshisoft.captions.models.ass.ASSStyle;
	import flash.text.engine.TextLine;
	
	import com.kenshisoft.captions.formats.IRenderer;
	import com.kenshisoft.captions.models.IStyle;
	
	/**
	 * ...
	 * @author ...
	 */
	public class SubtitleWord
	{
		public var text:String;
		public var style:ASSStyle;
		public var styleStr:String;
		
		private var _isLineBreak:Boolean = false;
		private var _isWhiteSpace:Boolean = false;
		private var _width:int = 0;
		private var _pixelWidth:Number = 0;
		private var _ascent:Number = 0;
		private var _descent:Number = 0;
		private var _leading:Number = 0;
		private var _textLine:TextLine;
		
		//TODO: testing
		public var pixelHeight:Number = 0;
		public var pixelLeading:Number = 0;
		
		//TODO: kara
		public var _ktype:int;
		public var _kstart:int;
		public var _kend:int;
		
		public function SubtitleWord(text:String, style:ASSStyle, renderer:ASSRenderer, styleStr:String)
		{
			super();
			
			this.text = text;
			this.style = style;
			this.styleStr = styleStr;
			
			if (text == '\n') _isLineBreak = true;
			if (text == ' ') _isWhiteSpace = true;
			
			_textLine = renderer.renderText(text, style);
			
			var textWidth:Number = 0;
			for (var i:int; i < _textLine.atomCount; i++)
				textWidth += _textLine.getAtomBounds(i).width;
			
			_ascent = _textLine.ascent;
			_descent = _textLine.descent;
			_leading = (_ascent + _descent) * 0.2;
			
			/*if (_isLineBreak)
				return;*/
			
			_pixelWidth = style.fontScaleX / 100 * textWidth + style.fontSpacing;
			
			//TODO: testing
			pixelHeight = style.fontScaleY / 100 * (_isLineBreak ? _descent * 1.5 : (_ascent + _descent));
			pixelLeading = style.fontScaleY / 100 * _leading;
			
			_width = int((style.fontScaleX / 100 * textWidth + 4/*1*/) >> 3); // word wrap mahou
		}
		
		public function get isLineBreak():Boolean
		{
			return _isLineBreak;
		}
		
		public function get isWhiteSpace():Boolean
		{
			return _isWhiteSpace
		}
		
		public function get width():int
		{
			return _width;
		}
		
		public function get pixelWidth():Number
		{
			return _pixelWidth;
		}
		
		public function get ascent():Number
		{
			return _ascent;
		}
		
		public function get descent():Number
		{
			return _descent;
		}
		
		public function get leading():Number
		{
			return _leading;
		}
		
		public function get textLine():TextLine
		{
			return _textLine;
		}
	}
}
