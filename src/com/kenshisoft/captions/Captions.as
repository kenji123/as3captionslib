/**
 * Copyright 2011-2012 Jamal Edey
 * 
 * This file is part of as3captionslib.
 * 
 * as3captionslib is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * as3captionslib is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with as3captionslib.  If not, see <http://www.gnu.org/licenses/>.
 */

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
	
	public class Captions
	{
		public var enabled:Boolean;
		public var animated:Boolean;
		
		private var _container:DisplayObjectContainer;
		private var _stream:NetStream;
		private var _videoRect:Rectangle;
		private var _captionsFormat:SubtitleFormat;
		private var _fontClasses:Vector.<FontClass> = new Vector.<FontClass>;
		private var _rawCaptions:String;
		private var _renderer:ASSRenderer = new ASSRenderer();
		private var _parsedCaptions:ASSSubtitle;
		public var _captionsTimeLine:CaptionsTimeLine;
		
		public var fontsRegisteredSignal:Signal = new Signal(Object);
		
		public var captionsLoadedSignal:Signal = new Signal(String);
		public var captionsParsedSignal:Signal = new Signal(SubtitleFormat, Object);
		
		public var captionDisplayedSignal:Signal = new Signal(ASSCaption);
		public var captionRemovedSignal:Signal = new Signal(ASSCaption);
		
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
		
		public function loadCaptions(format:SubtitleFormat, url:String):void
		{
			_captionsFormat = format;
			
			var subtitleLoader:SubtitleLoader = new SubtitleLoader();
			subtitleLoader.subtitleLoadedSignal.add(onCaptionsLoaded);
			subtitleLoader.load(url);
		}
		
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
		
		public function setCaptionsAnimated(animated:Boolean):void
		{
			this.animated = animated;
			
			if (_captionsTimeLine != null)
				_captionsTimeLine.animated = animated;
			
			flush();
		}
		
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
		
		public function setStream(stream:NetStream):void
		{
			_stream = stream;
			
			if (_captionsTimeLine != null)
				_captionsTimeLine.setStream(_stream);
		}
		
		public function setVideoRect(videoRect:Rectangle):void
		{
			_videoRect = videoRect;
			
			if (_captionsTimeLine != null)
				_captionsTimeLine.setVideoRect(_videoRect)
		}
		
		public function get captionsFormat():SubtitleFormat
		{
			return _captionsFormat;
		}
		
		public function get rawCaptions():String
		{
			return _rawCaptions;
		}
		
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