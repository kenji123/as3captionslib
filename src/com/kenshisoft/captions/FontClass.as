/**
 * Copyright 2011-2012 Jamal Edey
 * 
 * This file is part of as3captionslib.
 * 
 * as3captionslib is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * as3captionslib is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with as3captionslib.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.kenshisoft.captions
{
	/**
	 * ...
	 * @author 
	 */
	public class FontClass
	{
		public var properties:Object;
		
		private var _className:String;
		private var _fontFamily:String;
		private var _aliases:Array;
		
		public function FontClass(properties:Object)
		{
			super();
			
			this.properties = properties;
			
			_className = properties.className;
			_fontFamily = properties.fontFamily;
			_aliases = properties.aliases;
		}
		
		public function get className():String
		{
			return _className;
		}
		
		public function get fontFamily():String
		{
			return _fontFamily;
		}
		
		public function get aliases():Array
		{
			return _aliases;
		}
	}
}
