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

package com.kenshisoft.captions.config
{
	import com.kenshisoft.captions.FontClass;
	
	/**
	 * The FontConfig class represents the details of a SWF font resource.
	 * 
	 * @playerversion Flash 10.3
	 * @langversion 3.0
	 */
	public class FontConfig
	{
		/**
		 * The unparsed JSON representation of this this class.
		 */
		public var properties:Object;
		
		private var _url:String;
		private var _swfClass:String;
		private var _fontClasses:Vector.<FontClass> = new Vector.<FontClass>;
		private var _registered:Boolean = false;
		
		/**
		 * Creates a FontConfig class.
		 * 
		 * @param	properties	JSON string of this class.
		 */
		public function FontConfig(properties:Object)
		{
			super();
			
			this.properties = properties;
			
			_url = properties.url;
			_swfClass = properties.swfClass;
			for (var f:String in properties.fontClasses)
               _fontClasses.push(new FontClass(properties.fontClasses[f]))
		}
		
		/**
		 * The resource locator of the SWF font.
		 */
		public function get url():String
		{
			return _url;
		}
		
		/**
		 * The class name of the SWF resource.
		 */
		public function get swfClass():String
		{
			return _swfClass;
		}
		
		/**
		 * The details of all the fonts contained in this font resource.
		 */
		public function get fontClasses():Vector.<FontClass>
		{
			return _fontClasses;
		}
		
		/**
		 * Indicates whether the fonts of this resource have been registered in the global font list.
		 */
		public function get registered():Boolean
		{
			return _registered;
		}
		
		/**
		 * @private
		 */
		public function set registered(value:Boolean):void
		{
			_registered = value;
		}
	}
}