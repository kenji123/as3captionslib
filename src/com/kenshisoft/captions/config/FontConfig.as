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

package com.kenshisoft.captions.config
{
	import com.kenshisoft.captions.FontClass;
	
	/**
	 * ...
	 * @author 
	 */
	public class FontConfig
	{
		public var properties:Object;
		
		private var _url:String;
		private var _swfClass:String;
		private var _fontClasses:Vector.<FontClass> = new Vector.<FontClass>;
		private var _registered:Boolean = false;
		
		public function FontConfig(properties:Object)
		{
			super();
			
			this.properties = properties;
			
			_url = properties.url;
			_swfClass = properties.swfClass;
			for (var f:String in properties.fontClasses)
               _fontClasses.push(new FontClass(properties.fontClasses[f]))
		}
		
		public function get url():String
		{
			return _url;
		}
		
		public function get swfClass():String
		{
			return _swfClass;
		}
		
		public function get fontClasses():Vector.<FontClass>
		{
			return _fontClasses;
		}
		
		public function get registered():Boolean
		{
			return _registered;
		}
		
		public function set registered(value:Boolean):void
		{
			_registered = value;
		}
	}
}