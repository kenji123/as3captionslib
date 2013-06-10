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
	import com.kenshisoft.captions.formats.ICaption;
	import com.kenshisoft.captions.formats.IParser;
	import com.kenshisoft.captions.formats.IRenderer;
	import com.kenshisoft.captions.models.IEvent;
	import com.kenshisoft.captions.models.ISubtitle;
	
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author 
	 */
	public class SRTRenderer implements IRenderer
	{
		private var _parser:SRTParser;
		
		public function SRTRenderer()
		{
			super();
			
			_parser = new SRTParser();
		}
		
		public function render(subtitle_:ISubtitle, event_:IEvent, videoRect:Rectangle, container:DisplayObjectContainer, time:Number = -1, animate:Boolean = true, caption_:ICaption = null):ICaption
		{
			return null;
		}
		
		public function add(caption_:ICaption, captionsOnDisplay_:Vector.<ICaption>, container:DisplayObjectContainer, rerender:Boolean = false):void
		{
			
		}
		
		public function remove(caption_:ICaption, container:DisplayObjectContainer):void
		{
			
		}
		
		public function get parser():IParser
		{
			return _parser;
		}
	}
}
