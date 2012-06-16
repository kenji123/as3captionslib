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
	 * captions:Array
	 * 		url:String
	 * 		format:String
	 * 		name:String
	 * 		language:String
	 * 		defaultCaption:Boolean
	 * fonts:Array
	 * 		url:String
	 * 		swfClass:String
	 * 		fontClasses:Array
	 * 			className:String
	 * 			fontFamily:String
	 * 			aliases:Array
	 * 		url:String
	 * 		fontClass:String
	 * 		names:Array
	 * animateCaptions:Boolean
	 */
	
	/**
	 * ...
	 * @author 
	 */
	public class Config
	{
		public var parameters:Object;
		
		private var _captions:Vector.<CaptionConfig> = new Vector.<CaptionConfig>;
		private var _fonts:Vector.<FontConfig> = new Vector.<FontConfig>;
		private var _animateCaptions:Boolean;
		
		public function Config(parameters:Object)
		{
			super();
			
			this.parameters = parameters;
			
			for (var c:String in parameters.captions)
				_captions.push(new CaptionConfig(parameters.captions[c]));
			for (var f:String in parameters.fonts)
				_fonts.push(new FontConfig(parameters.fonts[f]));
			_animateCaptions = parameters.animateCaptions;
		}
		
		public function get captions():Vector.<CaptionConfig>
		{
			return _captions;
		}
		
		public function get fonts():Vector.<FontConfig>
		{
			return _fonts;
		}
		
		public function get animateCaptions():Boolean
		{
			return _animateCaptions;
		}
		
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