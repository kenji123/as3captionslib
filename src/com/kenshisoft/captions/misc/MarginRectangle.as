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

package com.kenshisoft.captions.misc
{
	/**
	 * ...
	 * @author Jamal Edey
	 */
	public class MarginRectangle
	{
		public var left:int;
		public var right:int;
		public var top:int;
		public var bottom:int;
		
		private var _width:int = 0;
		private var _height:int = 0;
		
		public function MarginRectangle(left:int = 0, right:int = 0, top:int = 0, bottom:int = 0)
		{
			super();
			
			this.left = left;
			this.right = right;
			this.top = top;
			this.bottom = bottom;
		}
		
		public function get width():int
		{
			return _width;
		}
		
		public function set width(value:int):void
		{
			_width = value;
		}
		
		public function get height():int
		{
			return _height;
		}
		
		public function set height(value:int):void
		{
			_height = value;
		}
		
		public function copy():MarginRectangle
		{
			var newMR:MarginRectangle = new MarginRectangle();
			newMR.left = left;
			newMR.right = right;
			newMR.top = top;
			newMR.bottom = bottom;
			newMR.width = _width;
			newMR.height = _height;
			
			return newMR;
		}
	}
}
