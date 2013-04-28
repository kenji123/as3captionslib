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
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.text.Font;
	
	import org.osflash.signals.Signal;
	
	import com.kenshisoft.captions.config.FontConfig;
	
	/**
	 * The FontLoader class downloads and registers fonts embeded in SWF resources. It also provides useful font related functions.
	 * 
	 * @playerversion Flash 10.3
	 * @langversion 3.0
	 */
	public class FontLoader
	{
		private var _font:FontConfig;
		private var _loader:Loader;
		private var _fontLibrary:Class;
		
		/**
		* Dispatched when a font(s) is registered. 
		* Returns the associated FontConfig object.
		*/
		public var fontsRegisteredSignal:Signal = new Signal(FontConfig);
		
		/**
		 * Creates a FontLoader object.
		 */
		public function FontLoader()
		{
			super();
		}
		
		private function downloadFontSwf():void
		{
			_loader = new Loader();
            _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onDownloadComplete);
			_loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			
			var urlRequest:URLRequest = new URLRequest(_font.url);
			urlRequest.method = URLRequestMethod.GET;
            urlRequest.requestHeaders.push(new URLRequestHeader("pragma", "no-cache"));
			
			var context:LoaderContext = new LoaderContext();
			context.securityDomain = SecurityDomain.currentDomain;
			context.applicationDomain = ApplicationDomain.currentDomain;
			
            try
			{
                //_loader.load(urlRequest, context);
                _loader.load(urlRequest);
            }
			catch (error:Error)
			{
                trace("FontLoader downloadFont: " + error.getStackTrace());
            }
		}
		
		private function onDownloadComplete(event:Event):void
		{
            //trace("FontLoader onDownloadComplete: " + _loader.contentLoaderInfo.bytesLoaded);
			
			registerFonts(_loader.contentLoaderInfo.applicationDomain);
        }
		
		private function onHttpStatus(event:HTTPStatusEvent):void
		{
			//trace("FontLoader onHttpStatus: " + event.status);
		}
		
		private function registerFonts(domain:ApplicationDomain):void
		{
			_fontLibrary = (domain.getDefinition(_font.swfClass)) as Class;
			
 	 	 	for (var i:int; i < _font.fontClasses.length; i++)
				Font.registerFont(_fontLibrary[_font.fontClasses[i].className]);
			
			fontsRegisteredSignal.dispatch(_font);
 	 	}
		
		/**
		 * Begins the process of downloading the SWF resource.
		 * 
		 * @param	font	The FontConfig object of the SWF resource.
		 */
		public function load(font:FontConfig):void
		{
			_font = font;
			
			downloadFontSwf();
		}
		
		/**
		 * Stops the download of the SWF resource. 
		 * If the download is already complete, this function has no affect.
		 */
		public function cancel():void
		{
			if (_loader != null)
				_loader.close();
		}
		
		/**
		 * Determines if a font is registed in the global font list.
		 * 
		 * @param	name			The name of the font.
		 * @param	embededOnly		Whether to only search the list of embeded fonts.
		 * @param	enumerateFonts	Whether to enumerate a list of fonts to search. If false, the fonts parameter must be non-null.
		 * @param	fonts			List of fonts to search through.
		 * @param	fontType		The FontType of the font to search for. Example: FontType.DEVICE.
		 * @return					A boolean value indicating whether the font is registered or not.
		 */
		public static function isFontRegistered(name:String, embededOnly:Boolean = true, enumerateFonts:Boolean = true, fonts:Array = null, fontType:String = null):Boolean
		{
			var fontList:Array = enumerateFonts ? Font.enumerateFonts(!embededOnly) : fonts;
			
			for (var i:int; i < fontList.length; i++)
			{
				if (fontList[i].fontName == name)
				{
					if (fontType == null)
					{
						return true;
					}
					else
					{
						if (fontList[i].fontType == fontType)
							return true;
					}
				}
			}
			
			return false;
		}
		
		/**
		 * Returns an enumerated list of the globally registered fonts.
		 * 
		 * @param	embededOnly	Whether this list will only include embeded fonts.
		 * @return				An array of globally registered fonts.
		 */
		public static function getRegisteredFonts(embededOnly:Boolean = true):Array
		{
			return Font.enumerateFonts(!embededOnly);
		}
		
		/**
		 * Returns an array of the details of fonts that matched the name and font type specified.
		 * 
		 * @param	name		The name of the font.
		 * @param	embededOnly	Whether to only search the list of embeded fonts.
		 * @param	fontType	The FontType of the font to search for. Example: FontType.DEVICE.
		 * @return				The array of fonts found.
		 */
		public static function getRegisteredFont(name:String, embededOnly:Boolean = true, fontType:String = null):Array
		{
			var fontList:Array = Font.enumerateFonts(!embededOnly);
			
			var fontsFound:Array = new Array();
			
			for (var i:String in fontList)
			{
				if (fontList[i].fontName == name)
				{
					if (fontType == null)
					{
						fontsFound.push(fontList[i]);
					}
					else
					{
						if (fontList[i].fontType == fontType)
							fontsFound.push(fontList[i]);
					}
				}
			}
			
			return fontsFound;
		}
	}
}
