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

package com.kenshisoft.captions.loaders
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.net.URLLoader;
    import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	import org.osflash.signals.Signal;
	
	/**
	 * The SubtitleLoader class downloads subtitle resources.
	 * 
	 * @playerversion Flash 10.3
	 * @langversion 3.0
	 */
	public class SubtitleLoader
	{
		private var _subtitleUrl:String;
		private var _urlLoader:URLLoader;
		
		/**
		* Dispatched when a subtitle resource is loaded. 
		* Returns the loaded subtitle resource as a string.
		*/
		public var subtitleLoadedSignal:Signal = new Signal(Object);
		
		/**
		 * Creates a SubtitleLoder object.
		 */
		public function SubtitleLoader()
		{
			super();
		}
		
		private function downloadSubtitle():void
		{
			_urlLoader = new URLLoader();
            _urlLoader.addEventListener(Event.COMPLETE, onDownloadComplete);
			_urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			
			var urlRequest:URLRequest = new URLRequest(_subtitleUrl);
			urlRequest.method = URLRequestMethod.GET;
            urlRequest.requestHeaders.push(new URLRequestHeader("pragma", "no-cache"));
			
            try
			{
                _urlLoader.load(urlRequest);
            }
			catch (error:Error)
			{
                trace("SubtitleLoader downloadSubtitle: " + error.getStackTrace());
            }
		}
		
		private function onDownloadComplete(event:Event):void
		{
            //trace("SubtitleLoader onDownloadComplete: " + _urlLoader.data);
			
			subtitleLoadedSignal.dispatch(_urlLoader.data);
        }
		
		private function onHttpStatus(event:HTTPStatusEvent):void
		{
			//trace("SubtitleLoader onHttpStatus: " + event.status);
		}
		
		/**
		 * Begins the process of downloading the subtitle resource.
		 * 
		 * @param	url	The resource locator of the subtitle.
		 */
		public function load(url:String):void
		{
			_subtitleUrl = url;
			
			downloadSubtitle();
		}
		
		/**
		 * Stops the download of the subtitle resource. 
		 * If the download is already complete, this function has no affect.
		 */
		public function cancel():void
		{
			if (_urlLoader != null)
				_urlLoader.close();
		}
	}
}