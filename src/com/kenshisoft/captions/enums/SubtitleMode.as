﻿//
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

package com.kenshisoft.captions.enums
{
	public class SubtitleMode
	{
		public static const TIME:SubtitleMode = new SubtitleMode("TIME");
		public static const FRAME:SubtitleMode = new SubtitleMode("FRAME");
		
		public var mode:String;
		
		public function SubtitleMode(mode:String)
		{
			super();
			
			this.mode = mode;
		}
	}
}
