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
	import com.kenshisoft.captions.enums.SubtitleMode;
	import com.kenshisoft.captions.misc.Size;
	
	/**
	 * ...
	 * @author 
	 */
	public class STS
	{
		private var _mode:SubtitleMode = SubtitleMode.TIME;
		private var _screenSize:Size = new Size();
		private var _wrapStyle:int = 0;
		private var _collisions:int = 0;
		private var _scaledBorderAndShadow:Boolean = false;
		
		private var _events:Vector.<IEvent> = new Vector.<IEvent>;
		
		public function STS()
		{
			super();
		}
		
		public function get events():Vector.<IEvent>
        {
            return _events;
		}
		
		public function get mode():SubtitleMode
		{
			return _mode;
		}
		
		public function set mode(value:SubtitleMode):void
		{
			_mode = value;
		}
		
		public function get screenSize():Size
		{
			return _screenSize;
		}
		
		public function set screenSize(value:Size):void
		{
			_screenSize = value;
		}
		
		public function get wrapStyle():int
		{
			return _wrapStyle;
		}
		
		public function set wrapStyle(value:int):void
		{
			_wrapStyle = value;
		}
		
		public function get collisions():int
		{
			return _collisions;
		}
		
		public function set collisions(value:int):void
		{
			_collisions = value;
		}
		
		public function get scaledBorderAndShadow():Boolean
		{
			return _scaledBorderAndShadow;
		}
		
		public function set scaledBorderAndShadow(value:Boolean):void
		{
			_scaledBorderAndShadow = value;
		}
		
       	public function set events(value:Vector.<IEvent>):void
        {
            _events = value;
		}
	}
}
