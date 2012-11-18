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
	/**
	 * The CaptionConfig class represents the details of a subtitle resource.
	 * 
	 * @playerversion Flash 10.3
	 * @langversion 3.0
	 */
	public class CaptionConfig
	{
		/**
		 * The unparsed JSON representation of this this class.
		 */
		public var properties:Object;
		
		private var _url:String;
		private var _format:String;
		private var _name:String;
		private var _language:String;
		private var _defaultCaption:Boolean;
		
		/**
		 * Creates a CaptionConfig class.
		 * 
		 * @param	properties	JSON string of this class.
		 */
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
		
		/**
		 * The resource locator of the subtitle.
		 */
		public function get url():String
		{
			return _url;
		}
		
		/**
		 * The format of the subtitle. 
		 * This value should match the string representation of the equivalent SubtitleFormat.
		 */
		public function get format():String
		{
			return _format;
		}
		
		/**
		 * The string identifier of the subtitle.
		 */
		public function get name():String
		{
			return _name;
		}
		
		/**
		 * The language if the contained captions of the subtitle.
		 */
		public function get language():String
		{
			return _language;
		}
		
		/**
		 * Indicates whether this subtitle is rendered by default, if not otherwise specified.
		 */
		public function get defaultCaption():Boolean
		{
			return _defaultCaption;
		}
	}
}