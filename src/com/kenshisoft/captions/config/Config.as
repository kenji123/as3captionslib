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

package com.kenshisoft.captions.config
{	
	/**
	 * The Config class represents the details of a subtitle resource.
	 * 
	 * <listing version="3.0">
	 * captions:Array
	 * 		url:String
	 * 		format:SubtitleFormat
	 * 		name:String
	 * 		language:String
	 * 		defaultCaption:Boolean
	 * 		fonts:Array
	 * 			url:String
	 * 			swfClass:String
	 * 			fontClasses:Array
	 * 				className:String
	 * 				fontFamily:String
	 * 				aliases:Array
	 * animateCaptions:Boolean
	 * </listing>
	 * 
	 * @playerversion Flash 10.3
	 * @langversion 3.0
	 */
	public class Config
	{
		/**
		 * The unparsed JSON representation of this class.
		 */
		public var parameters:Object;
		
		private var _captions:Vector.<CaptionConfig> = new Vector.<CaptionConfig>;
		private var _captionsEnabled:Boolean;
		private var _captionsAnimated:Boolean;
		
		/**
		 * Creates a Config class.
		 * 
		 * @param	parameters	JSON string of this class.
		 */
		public function Config(parameters:Object)
		{
			super();
			
			this.parameters = parameters;
			
			for (var c:String in parameters.captions)
				_captions.push(new CaptionConfig(parameters.captions[c]));
			_captionsEnabled = parameters.captionsEnabled;
			_captionsAnimated = parameters.captionsAnimated;
		}
		
		/**
		 * Collection of CaptionConfig objects of the configured subtitles.
		 */
		public function get captions():Vector.<CaptionConfig>
		{
			return _captions;
		}
		
		/**
		 * Indicates whether the captions will be enabled.
		 */
		public function get captionsEnabled():Boolean
		{
			return _captionsEnabled;
		}
		
		/**
		 * Indicates whether the captions will be animated.
		 */
		public function get captionsAnimated():Boolean
		{
			return _captionsAnimated;
		}
		
		/**
		 * Returns the first CaptionConfig marked as default in the subtitle collection. 
		 * If non are marked as default, the first subtitle in the collection is returned.
		 * 
		 * @return	The CaptionConfig of the subtitle resource.
		 */
		public function getDefaultCaption():CaptionConfig
		{
			for (var i:String in _captions)
			{
				if (_captions[i].defaultCaption)
					return _captions[i];
			}
			
			return _captions[0];
		}
	}
}
