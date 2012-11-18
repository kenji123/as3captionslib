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
		public var captions:ASSSubtitle;
		/**
		 * Font class objects of loaded fonts.
		 */
		public var fontClasses:Vector.<FontClass>;
		/**
		 * Whether captions are animated.
		 */
		public var animated:Boolean;
		/**
		 * The relevant rendering object that will render the captions of the subtitle object.
		 */
		public var renderer:ASSRenderer;
		
		private var _container:DisplayObjectContainer;
		private var _stream:NetStream;
		private var _videoRect:Rectangle;
		private var _captionsBuffer:Vector.<ASSCaption> = new Vector.<ASSCaption>;
		private var _captionsOnDisplay:Vector.<ASSCaption> = new Vector.<ASSCaption>;
		private var _captionsToRemove:Vector.<ASSCaption> = new Vector.<ASSCaption>;
		private var _captionsToAdd:Vector.<ASSCaption> = new Vector.<ASSCaption>;
		private var _captionsEnabled:Boolean = false;
		private var _bufferTimer:Timer;
		private var _timeLineTimer:Timer;
		private var _stageTimer:Timer;
		private var _currentTime:Number = 0;
		private var _lastBufferIndex:int = 0;
		
		/**
		* Dispatched when a caption is addded to the captions container. 
		* Returns the ASSCaption object displayed.
		*/
		public var captionDisplaySignal:Signal = new Signal(ASSCaption);
		/**
		* Dispatched when a caption is removed from the captions container. 
		* Returns the ASSCaption object removed.
		*/
		public var captionRemoveSignal:Signal = new Signal(ASSCaption);
		
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
		public function CaptionsTimeLine(format:SubtitleFormat, captions:ASSSubtitle, fontClasses:Vector.<FontClass>, animated:Boolean, renderer:ASSRenderer)
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
			
			_stageTimer = new Timer(20);
			//_stageTimer.addEventListener(TimerEvent.TIMER, stage);
		}
		
		/**
		 * Fills the captions buffer by prerendering captions up to the number of seconds assigned to BUFFER_LENGTH.
		 * 
		 * @param	event	The event dispatched by the associated Timer object.
		 */
		public function buffer(event:TimerEvent):void
		{
			_currentTime = _stream.time - sync;
			
			for (var i:int = _lastBufferIndex; i < captions.events.length; i++)
			{
				if (_currentTime >= captions.events[i].startSeconds && ((captions.events[i].startSeconds - _currentTime) < BUFFER_LENGTH))
				{
					_captionsBuffer.push(renderer.render(captions, captions.events[i], _videoRect, _container, _captionsOnDisplay, fontClasses, captions.events[i].startSeconds, animated));
					
					_lastBufferIndex++;
				}
				else
				{
					break;
				}
			}
		}
		
		private function timeLine(event:TimerEvent):void
		{
			_timeLineTimer.stop();
			
			_currentTime = _stream.time - sync;
			
			var caption:ASSCaption;
			
			for (var j:int; j < _captionsOnDisplay.length; j++)
			{
				if ((_captionsOnDisplay[j].isAnimated || _captionsOnDisplay[j].effects.COUNT > 0) && _currentTime < _captionsOnDisplay[j].event.endSeconds)
				{
					/*_captionsBuffer.push(renderer.render(ASSSubtitle(captions), _captionsOnDisplay[j].event.copy(), _videoRect, _container, _captionsOnDisplay, fontInfo, _stream.time, captionsAnimated));
					
					_captionsToRemove.push(_captionsOnDisplay.splice(j, 1)[0]);
					
					continue;*/
					
					caption = _captionsOnDisplay.splice(j, 1)[0];
					
					renderer.remove(caption, _container);
					
					var newCaption:ASSCaption = renderer.render(captions, caption.event.copy(), _videoRect, _container, _captionsOnDisplay, fontClasses, _stream.time, animated);
					
					renderer.add(newCaption, _captionsOnDisplay, _container);
					
					_captionsOnDisplay.push(newCaption);
					
					continue;
				}
				
				if (_currentTime < _captionsOnDisplay[j].event.startSeconds || _currentTime >= _captionsOnDisplay[j].event.endSeconds)
				{
					caption = _captionsOnDisplay.splice(j, 1)[0];
					
					caption.renderSprite.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved2);
					
					renderer.remove(caption, _container);
					
					captionRemoveSignal.dispatch(caption);
					
					return;
				}
			}
			
			for (var i:int; i < _captionsBuffer.length; i++)
			{
				if (_currentTime >= _captionsBuffer[i].event.startSeconds && _currentTime < _captionsBuffer[i].event.endSeconds)
				{
					caption = _captionsBuffer.splice(i, 1)[0];
					
					caption.renderSprite.addEventListener(Event.ADDED_TO_STAGE, onAdded2);
					
					renderer.add(caption, _captionsOnDisplay, _container);
					
					_captionsOnDisplay.push(caption);
					
					captionDisplaySignal.dispatch(caption);
					
					return;
				}
			}
			
			_timeLineTimer.start();
		}
		
		private function onRemoved2(event:Event):void
		{
			if (event) event.target.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			
			_timeLineTimer.start();
		}
		
		private function onAdded2(event:Event):void
		{
			if (event) event.target.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			_timeLineTimer.start();
		}
		
		private function stage(event:TimerEvent):void
		{
			_stageTimer.stop();
			
			//_container.alpha = 0;
			
			removeCaptions();
		}
		
		private function removeCaptions():void
		{
			if (format == SubtitleFormat.ASS)
			{
				var caption:ASSCaption;
				
				if (_captionsToRemove.length > 0)
				{
					//caption = ASSCaption(_captionsToRemove.splice(0, 1)[0]);
					
					caption.renderSprite.addEventListener(Event.EXIT_FRAME, onRemoved);
					
					//ASSRenderer.remove(caption, _container);
					
					captionRemoveSignal.dispatch(caption);
				}
				else
				{
					onRemoved(null);
				}
			}
		}
		
		private function addCaptions():void
		{
			if (format == SubtitleFormat.ASS)
			{
				var caption:ASSCaption;
				
				if (_captionsToAdd.length > 0)
				{
					//caption = ASSCaption(_captionsToAdd.splice(0, 1)[0]);
					
					caption.renderSprite.addEventListener(Event.ENTER_FRAME, onAdded);
					
					//ASSRenderer.add(caption, _captionsOnDisplay, _container);
					
					_captionsOnDisplay.push(caption);
					
					captionDisplaySignal.dispatch(caption);
				}
				else
				{
					onAdded(null);
				}
			}
		}
		
		private function onRemoved(event:Event):void
		{
			if (event) event.target.removeEventListener(Event.EXIT_FRAME, onRemoved);
			
			if (_captionsToRemove.length > 0)
			{
				removeCaptions();
			}
			else
			{
				addCaptions();
			}
		}
		
		private function onAdded(event:Event):void
		{
			if (event) event.target.removeEventListener(Event.ENTER_FRAME, onAdded);
			
			if (_captionsToAdd.length > 0)
			{
				addCaptions();
			}
			else
			{
				_container.alpha = 1;
				
				_stageTimer.start();
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
			//_stageTimer.start();
		}
		
		/**
		 * Pauses (stops) the internal timer and buffer of the timeline.
		 */
		public function pause():void
		{
			_captionsEnabled = false;
			
			_bufferTimer.stop();
			_timeLineTimer.stop();
			_stageTimer.stop();
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
			_captionsBuffer = new Vector.<ASSCaption>;
			_captionsToRemove = new Vector.<ASSCaption>;
			_captionsToAdd = new Vector.<ASSCaption>;
			
			time = (time > -1 ? time : _stream.time);
			
			for (var i:int; i < captions.events.length; i++)
			{
				if (captions.events[i].startSeconds >= time)
				{
					_lastBufferIndex = i;
					break;
				}
			}
		}
		
		/**
		 * Removes all captions currently in the caption display container.
		 */
		public function flushDisplay():void
		{
			_captionsOnDisplay = new Vector.<ASSCaption>;
			
			try
			{
				do
				{
					_container.removeChildAt(0);
				} while (_container.numChildren > 0);
			} catch (error:Error) { }
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
		public function get captionsBuffer():Vector.<ASSCaption>
		{
			return _captionsBuffer;
		}
		
		/**
		 * The captions currently on display.
		 */
		public function get captionsOnDisplay():Vector.<ASSCaption>
		{
			return _captionsOnDisplay;
		}
	}
}