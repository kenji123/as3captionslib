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

package com.kenshisoft.captions.formats.srt
{
	import com.kenshisoft.captions.FontClass;
	import com.kenshisoft.captions.formats.IParser;
	import com.kenshisoft.captions.misc.Util;
	import com.kenshisoft.captions.models.ISubtitle;
	import com.kenshisoft.captions.models.srt.SRTEvent;
	import com.kenshisoft.captions.models.srt.SRTSubtitle;
	
	/**
	 * ...
	 * @author 
	 */
	public class SRTParser implements IParser
	{
		
		public function SRTParser()
		{
			super();
		}
		
		public function parse(subtitleStr:String, fontClasses:Vector.<FontClass>):ISubtitle
		{
			var srtRegExp:RegExp = /(\d*)\r\n(\d\d:\d\d:\d\d,\d\d\d) --> (\d\d:\d\d:\d\d,\d\d\d)\r\n(.+?)\r\n\r\n/gis;
			
			var subtitle:SRTSubtitle = new SRTSubtitle();
			var index:int;
			
			var match:Object = srtRegExp.exec(subtitleStr);
			
			while (match != null)
			{
				index = 1;
				
				var event:SRTEvent = new SRTEvent();
				event.id = match[index++];
				event.start = match[index++];
				event.end = match[index++];
				event.text = String(match[index++]).replace(/\r\n/, "\n");
				
				event.startSeconds = Util.toSeconds(event.start);
				event.endSeconds = Util.toSeconds(event.end);
				event.duration = event.endSeconds - event.startSeconds;
				
				subtitle.events.push(event);
				
				match = srtRegExp.exec(subtitleStr);
			}
			
			return subtitle;
		}
	}
}
