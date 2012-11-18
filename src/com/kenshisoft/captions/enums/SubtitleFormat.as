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

package com.kenshisoft.captions.enums
{
	/**
	 * The SubtitleFormat class contains enumerated constants of the supported subtitle formats.
	 * 
	 * @playerversion Flash 10.3
	 * @langversion 3.0
	 */
	public class SubtitleFormat
	{
		/**
		 * Indicates that this is a Advanced Substation Alpha subtitle.
		 */
		public static const ASS:SubtitleFormat = new SubtitleFormat("ASS");
		/**
		 * Indicates that this is a SubRip Text subtitle.
		 */
		public static const SRT:SubtitleFormat = new SubtitleFormat("SRT");
		/**
		 * Indicates that this is a Synchronized Accessible Media Interchange subtitle.
		 */
		public static const SAMI:SubtitleFormat = new SubtitleFormat("SAMI");
		
		/**
		 * Format of the subtitle.
		 * 
		 * @private
		 */
		public var format:String;
		
		/**
		 * Creates a SubtitleFormat object.
		 * 
		 * @param	format	Format of the subtitle.
		 * @private
		 */
		public function SubtitleFormat(format:String)
		{
			super();
			
			this.format = format;
		}
	}
}