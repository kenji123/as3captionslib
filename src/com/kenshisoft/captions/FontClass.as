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
	 * The FontClass class represents the details of a font embeded in a SWF resource.
	 * 
	 * @playerversion Flash 10.3
	 * @langversion 3.0
	 */
	public class FontClass
	{
		/**
		 * The unparsed JSON representation of this this class.
		 */
		public var properties:Object;
		
		private var _className:String;
		private var _fontFamily:String;
		private var _aliases:Array;
		
		/**
		 * Creates a FontClass object.
		 * 
		 * @param	properties	JSON string of this class.
		 */
		public function FontClass(properties:Object)
		{
			super();
			
			this.properties = properties;
			
			_className = properties.className;
			_fontFamily = properties.fontFamily;
			_aliases = properties.aliases;
		}
		
		/**
		 * The class name of the font as defined in the SWF resource.
		 */
		public function get className():String
		{
			return _className;
		}
		
		/**
		 * The font family of the fon as defined in the SWF resourcet.
		 */
		public function get fontFamily():String
		{
			return _fontFamily;
		}
		
		/**
		 * The alias names by which the font can be identified by. 
		 * In some cases the font family of the font and the name by which it is referred to in the subtitle will be differnt. 
		 * By specifying that difference here, the font family can still be properly found.
		 */
		public function get aliases():Array
		{
			return _aliases;
		}
	}
}