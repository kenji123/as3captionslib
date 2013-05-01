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
	import com.kenshisoft.captions.formats.ICaption;
	import com.kenshisoft.captions.formats.IRenderer;
	import com.kenshisoft.captions.models.ISubtitle;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	import org.osflash.signals.Signal;
	
	import com.kenshisoft.captions.formats.ass.ASSCaption;
	import com.kenshisoft.captions.formats.ass.ASSRenderer;
	import com.kenshisoft.captions.enums.SubtitleFormat;
	import com.kenshisoft.captions.misc.Size;
	import com.kenshisoft.captions.models.ass.ASSSubtitle;
	
	/**
	 * The CaptionTimeLine class manages the buffering and the displayment of captions.
	 * 
	 * @playerversion Flash 10.3
	 * @langversion 3.0
	 */
	public class CaptionsTimeLine
	{
		private const BUFFER_LENGTH:int = 30; // buffer in seconds
		
		/**
		 * Format of the current subtile object.
		 */
		public var format:SubtitleFormat;
		/**
		 * Parsed subtitle object.
		 */
		public var captions:ISubtitle;
		/**
		 * Font class objects of loaded fonts.
		 */
		public var fontClasses:Vector.<FontClass>;
		/**
		 * The relevant rendering object that will render the captions of the subtitle object.
		 */
		public var renderer:IRenderer;
		
		/**
		 * Whether captions are animated.
		 */
		private var _animated:Boolean;
		private var _timeShift:Number = 0;
		private var _container:DisplayObjectContainer;
		private var _stream:NetStream;
		private var _videoRect:Rectangle;
		private var _captionsBuffer:Vector.<ICaption> = new Vector.<ICaption>;
		private var _captionsOnDisplay:Vector.<ICaption> = new Vector.<ICaption>;
		private var _captionsEnabled:Boolean = false;
		private var _bufferTimer:Timer;
		private var _timeLineTimer:Timer;
		private var _currentTime:Number = 0;
		private var _lastBufferIndex:int = 0;
		
		/**
		* Dispatched when a caption is addded to the captions container. 
		* Returns the ASSCaption object displayed.
		*/
		public var _captionDisplaySignal:Signal = new Signal(ICaption);
		public function get captionDisplaySignal():Signal { return _captionDisplaySignal; }
		/**
		* Dispatched when a caption is removed from the captions container. 
		* Returns the ASSCaption object removed.
		*/
		public var _captionRemoveSignal:Signal = new Signal(ICaption);
		public function get captionRemoveSignal():Signal { return _captionRemoveSignal; }
		
		public var sync:Number = 0;
		
		/**
		 * Creates a CaptionsTimeLine object.
		 * 
		 * @param	format		Format of the current subtile object.
		 * @param	captions	Parsed subtitle object.
		 * @param	fontClasses	A collection of FontClass objects of the loaded fonts.
		 * @param	animated	Whether captions are animated.
		 * @param	renderer	The relevant rendering object that will render the captions of the subtitle object.
		 */
		public function CaptionsTimeLine(format:SubtitleFormat, captions:ISubtitle, fontClasses:Vector.<FontClass>, animated:Boolean, renderer:IRenderer)
		{
			super();
			
			this.format = format;
			this.captions = captions;
			this.fontClasses = fontClasses;
			this.animated = animated;
			this.renderer = renderer;
			
			_bufferTimer = new Timer(20);
			_bufferTimer.addEventListener(TimerEvent.TIMER, buffer);
			
			_timeLineTimer = new Timer(20);
			_timeLineTimer.addEventListener(TimerEvent.TIMER, timeLine);
		}
		
		/**
		 * Fills the captions buffer by prerendering captions up to the number of seconds assigned to BUFFER_LENGTH.
		 * 
		 * @param	event	The event dispatched by the associated Timer object.
		 */
		private function buffer(event:TimerEvent):void
		{
			_currentTime = _stream.time - sync;
			
			switch (format)
			{
				case SubtitleFormat.ASS:
				case SubtitleFormat.CR:
					for (var i:int = _lastBufferIndex; i < captions.events.length; i++)
					{
						if (/*_currentTime >= captions.events[i].startSeconds &&*/ ((captions.events[i].startSeconds - _currentTime) < BUFFER_LENGTH))
						{
							_captionsBuffer.push(renderer.render(captions, captions.events[i], _videoRect, _container, _captionsOnDisplay, fontClasses, captions.events[i].startSeconds, animated));
							
							_lastBufferIndex++;
						}
						else
						{
							break;
						}
					}
					
					break;
			}
		}
		
		private function timeLine(event:TimerEvent):void
		{
			_currentTime = _stream.time - sync;
			
			var caption:ASSCaption;
			var removedCaption:Boolean = false;
			
			for (var j:int; j < _captionsOnDisplay.length; j++)
			{
				if ((_captionsOnDisplay[j].isAnimated || _captionsOnDisplay[j].effects.COUNT > 0) && _currentTime < _captionsOnDisplay[j].event.endSeconds)
				{
					caption = _captionsOnDisplay.splice(j, 1)[0];
					
					renderer.remove(caption, _container);
					
					var newCaption:ASSCaption = renderer.render(captions, caption.event, _videoRect, _container, _captionsOnDisplay, fontClasses, _stream.time, animated);
					
					renderer.add(newCaption, _captionsOnDisplay, _container);
					
					_captionsOnDisplay.push(newCaption);
					
					continue;
				}
				
				if (_currentTime < _captionsOnDisplay[j].event.startSeconds || _currentTime >= _captionsOnDisplay[j].event.endSeconds)
				{
					caption = _captionsOnDisplay.splice(j, 1)[0];
					
					renderer.remove(caption, _container);
					
					captionRemoveSignal.dispatch(caption);
					
					removedCaption = true;
				}
			}
			
			if (removedCaption) return;
			
			for (var i:int; i < _captionsBuffer.length; i++)
			{
				if (_currentTime >= _captionsBuffer[i].event.startSeconds && _currentTime < _captionsBuffer[i].event.endSeconds)
				{
					caption = _captionsBuffer.splice(i, 1)[0];
					
					renderer.add(caption, _captionsOnDisplay, _container);
					
					_captionsOnDisplay.push(caption);
					
					captionDisplaySignal.dispatch(caption);
				}
			}
		}
		
		/**
		 * Starts the internal timer and buffer of the timeline.
		 */
		public function start():void
		{
			_captionsEnabled = true;
			
			_bufferTimer.start();
			_timeLineTimer.start();
		}
		
		/**
		 * Pauses (stops) the internal timer and buffer of the timeline.
		 */
		public function pause():void
		{
			_captionsEnabled = false;
			
			_bufferTimer.stop();
			_timeLineTimer.stop();
		}
		
		/**
		 * Resumes the internal timer and buffer of the timeline.
		 */
		public function resume():void
		{
			start();
		}
		
		/**
		 * Empties the captions buffer and resets the buffer caption index.
		 * 
		 * @param	time	The time to reset the buffer index to. The currently associated NetStream.time is used by default.
		 */
		public function flushBuffer(time:Number = -1):void
		{
			_captionsBuffer = new Vector.<ICaption>;
			
			time = (time > -1 ? time : _stream.time);
			
			for (var i:int; i < captions.events.length; i++)
			{
				if (captions.events[i].startSeconds >= time)
				{
					_lastBufferIndex = i;
					break;
				}
			}
			
			flushDisplay();
		}
		
		/**
		 * Removes all captions currently in the caption display container.
		 */
		private function flushDisplay():void
		{
			_captionsOnDisplay = new Vector.<ICaption>;
			
			try
			{
				do
				{
					_container.removeChildAt(0);
				} while (_container.numChildren > 0);
			} catch (error:Error) { }
		}
		
		public function get animated():Boolean
		{
			return _animated;
		}
		
		public function set animated(value:Boolean):void
		{
			_animated = value;
		}
		
		public function get timeShift():Number
		{
			return _timeShift;
		}
		
		public function set timeShift(value:Number):void
		{
			_timeShift = value;
		}
		
		/**
		 * Sets the associated captions container.
		 * 
		 * @param	container	The captions container.
		 */
		public function setContainer(container:DisplayObjectContainer):void
		{
			_container = container;
		}
		
		/**
		 * Sets the associated NetStream of the video.
		 * 
		 * @param	stream	The NetStream of the video.
		 */
		public function setStream(stream:NetStream):void
		{
			_stream = stream;
		}
		
		/**
		 * Sets the associated video position resolution/bounds.
		 * 
		 * @param	videoRect	Position and size of the associated video.
		 */
		public function setVideoRect(videoRect:Rectangle):void
		{
			_videoRect = videoRect;
		}
		
		/**
		 * Vector object of the captions buffer.
		 */
		/*public function get captionsBuffer():Vector.<ASSCaption>
		{
			return _captionsBuffer;
		}*/
		
		/**
		 * The captions currently on display.
		 */
		/*public function get captionsOnDisplay():Vector.<ASSCaption>
		{
			return _captionsOnDisplay;
		}*/
	}
}