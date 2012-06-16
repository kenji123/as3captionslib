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
	/**
	 * ...
	 * @author 
	 */
	public class CaptionConfig
	{
		public var properties:Object;
		
		private var _url:String;
		private var _format:String;
		private var _name:String;
		private var _language:String;
		private var _defaultCaption:Boolean;
		
		public function CaptionConfig(properties:Object)
		{
			super();
			
			this.properties = properties;
			
			_url = properties.url;
			_format = properties.format;
			_name = properties.name;
			_language = properties.language;
			_defaultCaption = properties.defaultCaption;
		}
		
		public function get url():String
		{
			return _url;
		}
		
		public function get format():String
		{
			return _format;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get language():String
		{
			return _language;
		}
		
		public function get defaultCaption():Boolean
		{
			return _defaultCaption;
		}
	}
}