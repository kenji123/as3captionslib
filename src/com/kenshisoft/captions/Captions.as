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

package com.kenshisoft.captions
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.net.NetStream;
	
	import org.osflash.signals.Signal;
	
	import com.kenshisoft.captions.config.FontConfig;
	import com.kenshisoft.captions.formats.ass.ASSCaption;
	import com.kenshisoft.captions.formats.ass.ASSRenderer;
	import com.kenshisoft.captions.enums.SubtitleFormat;
	import com.kenshisoft.captions.loaders.FontLoader;
	import com.kenshisoft.captions.loaders.SubtitleLoader;
	import com.kenshisoft.captions.misc.Size;
	import com.kenshisoft.captions.models.ass.ASSSubtitle;
	import com.kenshisoft.captions.parsers.ASSParser;
	
	/**
	 * The Captions class provides the functionaltiy of displaying formated text based captions.
	 * 
	 * @playerversion Flash 10.3
	 * @langversion 3.0
	 */
	public class Captions
	{
		/**
		* Specifies whether the displaying of captions is enabled.
		* 
		* @default true
		*/
		public var enabled:Boolean;
		/**
		* Specifies whether the animation of captions is enabled.
		* 
		* @default true
		*/
		public var animated:Boolean;
		
		private var _container:DisplayObjectContainer;
		private var _stream:NetStream;
		private var _videoRect:Rectangle;
		private var _captionsFormat:SubtitleFormat;
		private var _fontClasses:Vector.<FontClass> = new Vector.<FontClass>;
		private var _rawCaptions:String;
		private var _renderer:ASSRenderer = new ASSRenderer();
		private var _parsedCaptions:ASSSubtitle;
		private var _captionsTimeLine:CaptionsTimeLine;
		
		/**
		* Dispatched when a font(s) is registered. 
		* Returns the associated FontConfig object.
		*/
		public var fontsRegisteredSignal:Signal = new Signal(Object);
		
		/**
		* Dispatched when a subtitle resource is loaded. 
		* Returns the loaded subtitle resource as a string.
		*/
		public var captionsLoadedSignal:Signal = new Signal(String);
		/**
		* Dispatched when a subtitle resource is parsed and is available as an object. 
		* Returns the SubtitleFormat and the parsed captions object.
		*/
		public var captionsParsedSignal:Signal = new Signal(SubtitleFormat, Object);
		
		/**
		* Dispatched when a caption has been addded to the associated captions display object container. 
		* Returns the ASSCaption object displayed.
		*/
		public var captionDisplayedSignal:Signal = new Signal(ASSCaption);
		/**
		* Dispatched when a caption has been removed from the associated captions display object container. 
		* Returns the ASSCaption object removed.
		*/
		public var captionRemovedSignal:Signal = new Signal(ASSCaption);
		
		/**
		 * Creates a Captions object.
		 * 
		 * @param	enabled		Whether captions are displayed as soon as they are available.
		 * @param	animated	Whether animation is rendered (for supported subtitle formats).
		 */
		public function Captions(enabled:Boolean = true, animated:Boolean = true)
		{
			super();
			
			this.enabled = enabled;
			this.animated = animated;
		}
		
		private function onCaptionsLoaded(event:Object):void
		{
			_rawCaptions = event.toString();
			
			captionsLoadedSignal.dispatch(_rawCaptions);
			
			parseCaptions();
		}
		
		private function parseCaptions():void
		{
			if(_captionsFormat == SubtitleFormat.ASS)
				_parsedCaptions = _renderer.parser.parse(rawCaptions, _fontClasses);
			
			captionsParsedSignal.dispatch(_captionsFormat, _parsedCaptions);
			
			initializeCaptionsTimeLine();
		}
		
		private function initializeCaptionsTimeLine():void
		{
			_captionsTimeLine = new CaptionsTimeLine(_captionsFormat, _parsedCaptions, _fontClasses, animated, _renderer);
			_captionsTimeLine.setContainer(_container);
			_captionsTimeLine.setStream(_stream);
			_captionsTimeLine.setVideoRect(_videoRect);
			_captionsTimeLine.captionDisplaySignal.add(onDisplayCaption);
			_captionsTimeLine.captionRemoveSignal.add(onRemoveCaption);
			
			if (enabled)
				_captionsTimeLine.start();
		}
		
		private function onDisplayCaption(event:ASSCaption):void
		{
			captionDisplayedSignal.dispatch(event);
		}
		
		private function onRemoveCaption(event:ASSCaption):void
		{
			captionRemovedSignal.dispatch(event);
		}
		
		/**
		 * Loads the font(s) stored in an external SWF resource.
		 * 
		 * @param	font	The FontConfig object of the SWF resource.
		 */
		public function loadFontSwf(font:FontConfig):void
		{
			for (var f:int; f < font.fontClasses.length; f++)
				_fontClasses.push(font.fontClasses[f])
			
			var fontLoader:FontLoader = new FontLoader();
			fontLoader.fontsRegisteredSignal.add(onFontsRegistered);
			fontLoader.load(font);
		}
		
		private function onFontsRegistered(event:Object):void
		{
			fontsRegisteredSignal.dispatch(event);
		}
		
		/**
		 * Loads the captions of an external subtitle resource.
		 * 
		 * @param	format	The SubtitleFormat of the subtitle resource to be loaded.
		 * @param	url		The URL of the subtitle resource.
		 */
		public function loadCaptions(format:SubtitleFormat, url:String):void
		{
			_captionsFormat = format;
			
			var subtitleLoader:SubtitleLoader = new SubtitleLoader();
			subtitleLoader.subtitleLoadedSignal.add(onCaptionsLoaded);
			subtitleLoader.load(url);
		}
		
		/**
		 * Flushes the pre-rendered captions buffer and captions currently on display. 
		 * If the time parameter > -1, then the buffer head is set to that time. 
		 * Otherwise the buffer head is set to the current value of the associated NetStream.time property. 
		 * This method must be called when the video is seeked or resized, to update the captions accordingly.
		 * 
		 * @param	time	The time in seconds to set the captions buffer head.
		 */
		public function flush(time:Number = -1):void
		{
			if (_captionsTimeLine != null)
			{
				if (enabled)
					_captionsTimeLine.pause();
				
				_captionsTimeLine.flushBuffer(time);
				_captionsTimeLine.flushDisplay();
				
				if (enabled)
					_captionsTimeLine.start();
			}
		}
		
		/**
		 * Pauses or resumes the CaptionsTimeLine to enable or disable shown captions.
		 * 
		 * @param	enabled	Whether captions are displayed.
		 */
		public function setCaptionsEnabled(enabled:Boolean):void
		{
			this.enabled = enabled;
			
			if (_captionsTimeLine != null && !enabled)
			{
				_captionsTimeLine.pause();
				_captionsTimeLine.flushDisplay();
			}
			else if (_captionsTimeLine != null && enabled)
			{
				_captionsTimeLine.flushBuffer();
				_captionsTimeLine.resume();
			}
		}
		
		/**
		 * Instantly enables or disables caption animation on the CaptionsTimeLine
		 * 
		 * @param	animated	Whether animated captions are rendered.
		 */
		public function setCaptionsAnimated(animated:Boolean):void
		{
			this.animated = animated;
			
			if (_captionsTimeLine != null)
				_captionsTimeLine.animated = animated;
			
			flush();
		}
		
		/**
		 * Sets the container within which the captions will be children of.
		 * 
		 * @param	container	The DisplayObjectContainer that all caption will be children of.
		 */
		public function setContainer(container:DisplayObjectContainer):void
		{
			_container = container;
			
			if (_captionsTimeLine != null)
				_captionsTimeLine.setContainer(_container);
			
			//_container.addChildAt(new Bitmap(new BitmapData(res.width, res.height, true, 0), "auto", false), 0);
			//_container.getChildAt(0).visible = false;
			//_container.addChildAt(new Bitmap(new BitmapData(res.width, res.height, true, 0), "auto", false), 1);
			//_container.addChildAt(new Bitmap(new BitmapData(res.width, res.height, true, 0), "auto", false), 2);
		}
		
		/**
		 * Assigns the NetStream object of the related video to the CaptionTimeLine.
		 * 
		 * @param	stream	The NetStream object of the video.
		 */
		public function setStream(stream:NetStream):void
		{
			_stream = stream;
			
			if (_captionsTimeLine != null)
				_captionsTimeLine.setStream(_stream);
		}
		
		/**
		 * Sets the resolution and location of the video, or the bounds that the captions will be placed/displayed within.
		 * 
		 * @param	videoRect	The bounds of the video which the captions will be placed.
		 */
		public function setVideoRect(videoRect:Rectangle):void
		{
			_videoRect = videoRect;
			
			if (_captionsTimeLine != null)
				_captionsTimeLine.setVideoRect(_videoRect)
		}
		
		/**
		 * The SubtitleFormat of the subtitle resource.
		 */
		public function get captionsFormat():SubtitleFormat
		{
			return _captionsFormat;
		}
		
		/**
		 * An unparsed string of the subtitle resource.
		 */
		public function get rawCaptions():String
		{
			return _rawCaptions;
		}
		
		/**
		 * The captions object of the parsed subtitle resource.
		 */
		public function get parsedCaptions():ASSSubtitle
		{
			return _parsedCaptions;
		}
		
		public function setSync(secs:Number):void
		{
			if (_captionsTimeLine != null)
				_captionsTimeLine.sync = secs;
			
			//trace(secs);
		}
	}
}