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

package com.kenshisoft.captions.models
{
	import com.kenshisoft.captions.misc.MarginRectangle;
	
	/**
	 * ...
	 * @author 
	 */
	public class STSEntry
	{
		private var _layer:int = 0;
		private var _start:String = "00:00:00.00"; // stored as parsed. use startSeconds for numeric converted value
		private var _end:String = "00:00:05.00"; // stored as parsed. use endSeconds for numeric converted value
		private var _style:String = "Default";
		private var _actor:String = "";
		private var _marginRect:MarginRectangle = new MarginRectangle(20, 20, 20, 20); // SRT = X1:left X2:right Y1:top Y2:bottom
		private var _effect:String = "";
		private var _text:String = "";
		
		public function STSEntry()
		{
			super();
		}
		
		public function get layer():int
		{
			return _layer;
		}
		
		public function set layer(value:int):void
		{
			_layer = value;
		}
		
		public function get start():String
		{
			return _start;
		}
		
		public function set start(value:String):void
		{
			_start = value;
		}
		
		public function get end():String
		{
			return _end;
		}
		
		public function set end(value:String):void
		{
			_end = value;
		}
		
		public function get style():String
		{
			return _style;
		}
		
		public function set style(value:String):void
		{
			_style = value;
		}
		
		public function get actor():String
		{
			return _actor;
		}
		
		public function set actor(value:String):void
		{
			_actor = value;
		}
		
		public function get marginRect():MarginRectangle
		{
			return _marginRect;
		}
		
		public function set marginRect(value:MarginRectangle):void
		{
			_marginRect = value;
		}
		
		public function get effect():String
		{
			return _effect;
		}
		
		public function set effect(value:String):void
		{
			_effect = value;
		}
		
		public function get text():String
		{
			return _text;
		}
		
		public function set text(value:String):void
		{
			_text = value;
		}
	}
}
