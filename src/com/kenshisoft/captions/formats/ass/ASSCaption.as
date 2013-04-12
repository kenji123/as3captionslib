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

package com.kenshisoft.captions.formats.ass
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import com.kenshisoft.captions.SubtitleLine;
	import com.kenshisoft.captions.SubtitleWord;
	import com.kenshisoft.captions.models.ass.ASSEvent;
	import com.kenshisoft.captions.misc.MarginRectangle;
	import com.kenshisoft.captions.misc.Position;
	import com.kenshisoft.captions.misc.VectorPosition;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ASSCaption
	{
		public var wrapStyle:int;
		public var alignment:int;
		public var event:ASSEvent;
		
		private var _orgWrapStyle:int;
		private var _isAnimated:Boolean = false;
		private var _words:Vector.<SubtitleWord> = new Vector.<SubtitleWord>;
		private var _lines:Vector.<SubtitleLine> = new Vector.<SubtitleLine>;
		private var _marginRect:MarginRectangle = new MarginRectangle();
		private var _rect:Rectangle = new Rectangle();
		private var _lineRects:Vector.<Rectangle> = new Vector.<Rectangle>;
		private var _relativeTo:int = 0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _effects:Object = new Object();
		private var _transformPoint:Point;
		private var _fax:int = 0;
		private var _fay:int = 0;
		private var _renderSprite:Sprite;
		
		//TODO: testing
		public var bitmap:Bitmap;
		
		public function ASSCaption(wrapStyle:int, alignment:int, event:ASSEvent)
		{
			super();
			
			this.wrapStyle = _orgWrapStyle = wrapStyle;
			this.alignment = -alignment;
			this.event = event;
			
			effects.COUNT = 0;
		}
		
		public function makeLines(marginRect:MarginRectangle):void
		{
			_marginRect = marginRect;
			
			var ret:SubtitleLine;
			var pos:Position = VectorPosition.getHeadPosition(_words);
			
			while (pos.notNull)
			{
				ret = getNextLine(pos, marginRect.width >> 3); // word wrap mahou
				if (!ret) break;
				
				addLine(ret, (pos.index == words.length-1 ? true : false));
			}
			
			if (alignment == 7 || alignment == 4 || alignment == 1)
				_rect.x = marginRect.left;
			if (alignment == 8 || alignment == 5 || alignment == 2)
				_rect.x = (marginRect.left + (marginRect.width / 2)) - (_rect.width / 2);
			if (alignment == 9 || alignment == 6 || alignment == 3)
				_rect.x = (marginRect.left + marginRect.width) - _rect.width;
			
			if (alignment == 7 || alignment == 8 || alignment == 9)
				_rect.y = marginRect.top;
			if (alignment == 4 || alignment == 5 || alignment == 6)
				_rect.y = (marginRect.top + (marginRect.height / 2)) - (_rect.height / 2);
			if (alignment == 1 || alignment == 2 || alignment == 3)
				_rect.y = (marginRect.top + marginRect.height) - _rect.height;
			
			for (var i:int; i < _lineRects.length; i++)
			{
				if (alignment == 7 || alignment == 4 || alignment == 1)
					_lineRects[i].x = 0;
				if (alignment == 8 || alignment == 5 || alignment == 2)
					_lineRects[i].x = (_rect.width / 2) - (_lineRects[i].width / 2);
				if (alignment == 9 || alignment == 6 || alignment == 3)
					_lineRects[i].x = _rect.width - _lineRects[i].width;
			}
		}
		
		private function getNextLine(pos:Position, maxWidth:int):SubtitleLine
		{
			if (!pos.notNull) return null;
			
			var ret:SubtitleLine = new SubtitleLine();
			if (!ret) return null;
			
			maxWidth = getWrapWidth(VectorPosition.getCurrentPosition(pos), maxWidth);
			
			var emptyLine:Boolean = true;
			
			while (pos.notNull)
			{
				var w:SubtitleWord = VectorPosition.getNext(pos, _words);
				
				if (w.isLineBreak)
				{
					if (emptyLine) { ret.addWord(w); ret.ascent /= 2;  ret.descent /= 2; ret.leading /= 2; }
					
					ret.compact();
					
					return ret;
				}
				
				emptyLine = false;
				
				var fWSC:Boolean = w.isWhiteSpace;
				
				var width:int = w.width;
				var pos2:Position = VectorPosition.getCurrentPosition(pos);
				while (pos2.notNull)
				{
					if (VectorPosition.getAt(pos2, _words).isWhiteSpace != fWSC
					|| VectorPosition.getAt(pos2, _words).isLineBreak)
						break;
					
					width += VectorPosition.getNext(pos2, _words).width;
				}
				
				if ((ret.width + width) <= maxWidth || ret.isEmpty)
				{
					ret.addWord(w);
					
					while (pos.index != pos2.index)
						ret.addWord(VectorPosition.getNext(pos, _words));
					
					pos.index = pos2.index;
				}
				else
				{
					if (pos.notNull) VectorPosition.getPrevious(pos, _words);
					else pos = VectorPosition.getTailPosition(_words);
					
					ret.width -= width;
					
					break;
				}
			}
			
			ret.compact();
			
			return ret;
		}
		
		private function getWrapWidth(pos:Position, maxWidth:int):int
		{
			if(wrapStyle == 0 || wrapStyle == 3)
			{
				if(maxWidth > 0)
				{
					var fullWidth:int = getFullLineWidth(VectorPosition.getCurrentPosition(pos));
					
					//var minwidth:int = fullwidth / ((Math.abs(fullwidth) / maxwidth) + 1); // from RTS.cpp
					var minWidth:int = fullWidth / int(((fullWidth > 0 ? fullWidth : -fullWidth) / maxWidth) + 1);
					//var minWidth:int = fullWidth / Math.ceil((fullWidth / maxWidth));
					
					var widthh:int = 0;
					var wordWidth:int = 0;
					
					while (pos.notNull && widthh < minWidth)
					{
						var w:SubtitleWord = VectorPosition.getNext(pos, _words);
						wordWidth = w.width;
						
						var ww:int = widthh + wordWidth;
						if ((ww > 0 ? ww : -ww) < (maxWidth > 0 ? maxWidth : -maxWidth))
							widthh += wordWidth;
					}
					
					maxWidth = widthh;
					
					if (wrapStyle == 3 && pos.notNull)
						maxWidth -= wordWidth;
				}
			}
			else if(wrapStyle == 1)
			{
				//maxWidth = maxWidth;
			}
			else if(wrapStyle == 2)
			{
				maxWidth = int.MAX_VALUE;
			}
			
			return maxWidth;
		}
		
		private function getFullLineWidth(pos:Position):int
		{
			var width:int = 0;
			
			while (pos.notNull)
			{
				var w:SubtitleWord = VectorPosition.getNext(pos, _words);
				
				if (w.isLineBreak) break;
				
				width += w.width;
			}
			
			return width;
		}
		
		private function addLine(line:SubtitleLine, last:Boolean):void
		{
			if (_lineRects.length == 0)
				_lineRects.push(new Rectangle(0, line.ascent, line.pixelWidth, (line.ascent + line.descent)));
			else
				_lineRects.push(new Rectangle(0, (_rect.height + line.ascent), line.pixelWidth, (line.ascent + line.descent)));
			
			_rect.width = line.pixelWidth > _rect.width ? line.pixelWidth : _rect.width;
			//_rect.height += line.ascent + line.descent + (last ? 0 : line.leading);
			
			//TODO: testing
			_rect.height += line.pixelHeight + (last ? 0 : line.pixelLeading);
			
			_lines.push(line);
		}
		
		public function get orgWrapStyle():int
		{
			return _orgWrapStyle;
		}
		
		public function get isAnimated():Boolean
		{
			return _isAnimated;
		}
		
		public function set isAnimated(value:Boolean):void
		{
			_isAnimated = value;
		}
		
		public function get words():Vector.<SubtitleWord>
		{
			return _words;
		}
		
		public function get lines():Vector.<SubtitleLine>
		{
			return _lines;
		}
		
		public function getMarginRect():MarginRectangle
		{
			return _marginRect;
		}
		
		public function getRect():Rectangle
		{
			return _rect;
		}
		
		public function getLineRects():Vector.<Rectangle>
		{
			return _lineRects;
		}
		
		public function get relativeTo():int
		{
			return _relativeTo;
		}
		
		public function set relativeTo(value:int):void
		{
			_relativeTo = value;
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
		
		public function get transformPoint():Point
		{
			return _transformPoint;
		}
		
		public function set transformPoint(value:Point):void
		{
			_transformPoint = value;
		}
		
		public function get fax():int
		{
			return _fax;
		}
		
		public function set fax(value:int):void
		{
			_fax = value;
		}
		
		public function get fay():int
		{
			return _fay;
		}
		
		public function set fay(value:int):void
		{
			_fay = value;
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