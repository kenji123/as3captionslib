//
// Copyright 2011-2012 Jamal Edey
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
	/**
	 * ...
	 * @author 
	 */
	public class SubtitleLine
	{
		private var _words:Vector.<SubtitleWord> = new Vector.<SubtitleWord>;
		private var _width:int = 0;
		private var _pixelWidth:Number = 0;
		private var _ascent:Number = 0;
		private var _descent:Number = 0;
		private var _leading:Number = 0;
		private var _text:String = '';
		
		//TODO: testing
		public var pixelHeight:Number = 0;
		public var pixelLeading:Number = 0;
		
		public function SubtitleLine()
		{
			super();
		}
		
		public function addWord(word:SubtitleWord):void
		{
			_width += word.width;
			
			_pixelWidth += word.pixelWidth;
			
			//TODO: testing
			pixelHeight = word.pixelHeight > pixelHeight ? word.pixelHeight : pixelHeight;
			pixelLeading = word.pixelLeading > pixelLeading ? word.pixelLeading : pixelLeading;
			
			_ascent = word.ascent > _ascent ? word.ascent : _ascent;
			_descent = word.descent > _descent ? word.descent : _descent;
			_leading = word.leading > _leading ? word.leading : _leading;
			
			_words.push(word);
		}
		
		public function compact():void
		{
			if (_words.length == 0) return;
			if (_words[0].isWhiteSpace)
			{
				_width -= _words[0].width;
				_pixelWidth -= _words[0].pixelWidth;
				_words.splice(0, 1);
			}
			
			if (_words.length == 0) return;
			if (_words[words.length-1].isWhiteSpace)
			{
				_width -= _words[words.length - 1].width;
				_pixelWidth -= _words[words.length - 1].pixelWidth;
				_words.splice(_words.length - 1, 1);
			}
			
			_text = '';
			for (var i:int; i < _words.length; i++)
				_text += _words[i].text;
		}
		
		public function get isEmpty():Boolean
		{
			return _words.length == 0 ? true : false;
		}
		
		public function get words():Vector.<SubtitleWord>
		{
			return _words;
		}
		
		public function get width():int
		{
			return _width;
		}
		
		public function set width(value:int):void
		{
			_width = value;
		}
		
		public function get pixelWidth():Number
		{
			return _pixelWidth;
		}
		
		public function get ascent():Number
		{
			return _ascent;
		}
		
		public function set ascent(value:Number):void
		{
			_ascent = value;
		}
		
		public function get descent():Number
		{
			return _descent;
		}
		
		public function set descent(value:Number):void
		{
			_descent = value;
		}
		
		public function get leading():Number
		{
			return _leading;
		}
		
		public function set leading(value:Number):void
		{
			_leading = value;
		}
		
		public function get text():String
		{
			return _text;
		}
	}
}