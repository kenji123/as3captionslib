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

package com.kenshisoft.captions
{
	import com.kenshisoft.captions.formats.ass.ASSCaption;
	import com.kenshisoft.captions.formats.ass.ASSEffect;
	import com.kenshisoft.captions.formats.ass.ASSRenderer;
	import com.kenshisoft.captions.formats.ICaption;
	import com.kenshisoft.captions.misc.MarginRectangle;
	import com.kenshisoft.captions.models.ass.ASSEvent;
	import com.kenshisoft.captions.models.ass.ASSStyle;
	import com.kenshisoft.captions.models.ass.ASSSubtitle;
	import com.kenshisoft.captions.models.IEvent;
	import com.kenshisoft.captions.models.ISubtitle;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	
	public class CaptionsWorker extends Sprite
	{
		private	var	_channelToMain:MessageChannel;
		private	var	_channelToWorker:MessageChannel;
		
		public function CaptionsWorker()
		{
			super();
			
			registerClassAlias("com.kenshisoft.captions.formats.ass.ASSSubtitle", ASSSubtitle);
			registerClassAlias("com.kenshisoft.captions.formats.ass.ASSStyle", ASSStyle);
			registerClassAlias("com.kenshisoft.captions.formats.ass.ASSEvent", ASSEvent);
			registerClassAlias("com.kenshisoft.captions.misc.MarginRectangle", MarginRectangle);
			registerClassAlias("com.kenshisoft.captions.FontClass", FontClass);
			
			initWorkerThread();
		}
		
		private function initWorkerThread():void
		{
			// get shared properties
			_channelToMain = Worker.current.getSharedProperty('C2M');
			_channelToWorker = Worker.current.getSharedProperty('C2W');
			
			// add event listener to channel
			_channelToWorker.addEventListener(Event.CHANNEL_MESSAGE, onMessageReceived);
		}
		
		private function onMessageReceived(event:Event):void
		{
			if (_channelToWorker.messageAvailable)
			{
				var b:ByteArray = _channelToWorker.receive() as ByteArray;
				b.position = 0;
				var m:Array = b.readObject();
				
				var renderer:ASSRenderer = new ASSRenderer();
				
				var fontClasses:Vector.<FontClass> = new Vector.<FontClass>;//m[0] as Vector.<FontClass>;
				var subtitle:ASSSubtitle = ASSSubtitle(renderer.parser.parse(m[1] as String, fontClasses));
				var sevent:ASSEvent = subtitle.events[(m[2] as int)];
				var videoRect:Rectangle = new Rectangle(m[3] as Number, m[4] as Number, m[5] as Number, m[6] as Number);
				var container:DisplayObjectContainer = new Sprite();
				container.width = m[7] as Number;
				container.height = m[8] as Number;
				var time:Number = m[9] as Number;
				var animated:Boolean = m[10] as Boolean;
				//var caption:ICaption = renderer.render(m[0] as ASSSubtitle, m[1] as ASSEvent, m[2] as Rectangle, m[3] as DisplayObjectContainer, m[4] as Vector.<FontClass>, null, m[5] as Number, m[6] as Boolean);
				var caption:ICaption = renderer.render(subtitle, sevent, videoRect, container, fontClasses, null, time, animated);
				
				var bitmapData:BitmapData = new BitmapData(videoRect.width, videoRect.height, true, 0x00FFFFFF);
				bitmapData.draw(caption.renderSprite, caption.renderSprite.transform.matrix);
				
				var c:ByteArray = new ByteArray();
				c.writeObject([0, m[1] as String, (m[2] as int), videoRect.x, videoRect.y, videoRect.width, videoRect.height, container.width, container.height, time, animated, bitmapData]);
				
				_channelToMain.send(c);
			}
		}
	}
}