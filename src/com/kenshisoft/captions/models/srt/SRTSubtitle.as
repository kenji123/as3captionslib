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

package com.kenshisoft.captions.models.srt
{
	import com.kenshisoft.captions.enums.SubtitleFormat;
	import com.kenshisoft.captions.models.ISubtitle;
	import com.kenshisoft.captions.models.STS;
	
	/**
	 * ...
	 * @author 
	 */
	public class SRTSubtitle extends STS implements ISubtitle
	{
		private static const FORMAT:SubtitleFormat = SubtitleFormat.SRT;
		
		public function SRTSubtitle()
		{
			super();
		}
		
		public function get format():SubtitleFormat
        {
            return FORMAT;
		}
	}
}
