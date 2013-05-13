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
	 * The Size class simply holds width and height values.
	 * 
	 * @playerversion Flash 10.3
	 * @langversion 3.0
	 */
	public class Size
	{
		/**
		 * The height.
		 * 
		 * @default 0
		 */
		public var width:int;
		/**
		 * The width.
		 * 
		 * @default 0
		 */
		public var height:int;
		
		/**
		 * Creates a Size object.
		 * 
		 * @param	width	The width.
		 * @param	height	The height.
		 */
		public function Size(width:int = 0, height:int = 0)
		{
			super();
			
			this.width = width;
			this.height = height;
		}
	}
}
