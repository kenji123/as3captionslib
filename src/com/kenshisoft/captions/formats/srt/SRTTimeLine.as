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
	import com.kenshisoft.captions.formats.IRenderer;
	import com.kenshisoft.captions.formats.ass.ASSRenderer;
	import com.kenshisoft.captions.formats.ass.ASSTimeLine;
	import com.kenshisoft.captions.models.ISubtitle;
	import com.kenshisoft.captions.models.ass.ASSSubtitle;
	import com.kenshisoft.captions.models.srt.SRTSubtitle;
	
	/**
	 * ...
	 * @author 
	 */
	public class SRTTimeLine extends ASSTimeLine
	{
		public function SRTTimeLine(captions:ISubtitle, renderer:IRenderer, animated:Boolean)
		{
			var subtitle:SRTSubtitle = SRTSubtitle(captions);
			
			var assSubtitle:ASSSubtitle = new ASSSubtitle();
			assSubtitle.mode = subtitle.mode;
			assSubtitle.screenSize = subtitle.screenSize;
			assSubtitle.wrapStyle = subtitle.wrapStyle;
			assSubtitle.collisions = subtitle.collisions;
			assSubtitle.scaledBorderAndShadow = subtitle.scaledBorderAndShadow;
			assSubtitle.events = subtitle.events;
			
			renderer = new ASSRenderer();
			
			super(assSubtitle, renderer, animated);
		}
	}
}
