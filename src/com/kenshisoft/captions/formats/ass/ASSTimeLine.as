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

package com.kenshisoft.captions.formats.ass
{
	import flash.display.DisplayObjectContainer;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.NetStream;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	import org.osflash.signals.Signal;
	
	import com.kenshisoft.captions.ICaptionsTimeLine;
	import com.kenshisoft.captions.formats.ICaption;
	import com.kenshisoft.captions.formats.IRenderer;
	import com.kenshisoft.captions.formats.ass.ASSCaption;
	import com.kenshisoft.captions.formats.ass.ASSRenderer;
	import com.kenshisoft.captions.models.ISubtitle;
	import com.kenshisoft.captions.models.ass.ASSSubtitle;
	
	/**
	 * The CaptionTimeLine class manages the buffering and the displayment of captions.
	 * 
	 * @playerversion Flash 10.3
	 * @langversion 3.0
	 */
	public class ASSTimeLine implements ICaptionsTimeLine
	{
		private const BUFFER_LENGTH:int = 30; // buffer in seconds
		
		/**
		 * Parsed subtitle object.
		 */
		public var captions:ASSSubtitle;
		/**
		 * The relevant rendering object that will render the captions of the subtitle object.
		 */
		public var renderer:ASSRenderer;
		
		/**
		 * Whether captions are animated.
		 */
		private var _animated:Boolean;
		public function get animated():Boolean { return _animated; };
		public function set animated(value:Boolean):void { _animated = value; };
		
		private var _timeShift:Number = 0;
		public function get timeShift():Number { return _timeShift; };
		public function set timeShift(value:Number):void { _timeShift = value; };
		
		private var _container:DisplayObjectContainer;
		private var _stream:NetStream;
		private var _videoRect:Rectangle;
		private var _captionsBuffer:Vector.<ASSCaption> = new Vector.<ASSCaption>;
		private var _captionsOnDisplay:Vector.<ASSCaption> = new Vector.<ASSCaption>;
		private var _captionsEnabled:Boolean = false;
		private var _bufferTimer:Timer;
		private var _timeLineTimer:Timer;
		private var _timeLine2Timer:Timer;
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
		
		/**
		 * Creates a ASSTimeLine object.
		 * 
		 * @param	captions	Parsed subtitle object.
		 * @param	renderer	The relevant rendering object that will render the captions of the subtitle object.
		 * @param	animated	Whether captions are animated.
		 */
		public function ASSTimeLine(captions:ISubtitle, renderer:IRenderer, animated:Boolean)
		{
			super();
			
			this.captions = ASSSubtitle(captions);
			this.renderer = ASSRenderer(renderer);
			
			_animated = animated;
			
			_bufferTimer = new Timer(16);
			_bufferTimer.addEventListener(TimerEvent.TIMER, buffer);
			
			_timeLineTimer = new Timer(16);
			_timeLineTimer.addEventListener(TimerEvent.TIMER, timeLine);
			
			_timeLine2Timer = new Timer(16);
			_timeLine2Timer.addEventListener(TimerEvent.TIMER, timeLine2);
		}
		
		/**
		 * Fills the captions buffer by prerendering captions up to the number of seconds assigned to BUFFER_LENGTH.
		 * 
		 * @param	event	The event dispatched by the associated Timer object.
		 */
		private function buffer(event:TimerEvent):void
		{
			_bufferTimer.stop();
			_timeLine2Timer.stop();
			
			_currentTime = _stream.time - _timeShift;
			
			var start:int = getTimer();
			
			for (var i:int = _lastBufferIndex; i < captions.events.length; i++)
			{
				if ((captions.events[i].startSeconds - _currentTime) < BUFFER_LENGTH)
				{
					_captionsBuffer.push(renderer.render(captions, captions.events[i], _videoRect, _container, captions.events[i].startSeconds, animated));
					
					_lastBufferIndex++;
					
					if (32 > (getTimer() - start)) break;
				}
				else
				{
					break;
				}
			}
			
			_timeLine2Timer.start();
			_bufferTimer.start();
		}
		
		private function timeLine(event:TimerEvent):void
		{
			_currentTime = _stream.time - _timeShift;
			
			var caption:ASSCaption;
			var removedCaption:Boolean = false;
			var start:int = getTimer();
			
			for (var j:int; j < _captionsOnDisplay.length; j++)
			{
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
					
					renderer.add(caption, Vector.<ICaption>(_captionsOnDisplay), _container);
					
					_captionsOnDisplay.push(caption);
					
					captionDisplaySignal.dispatch(caption);
				}
			}
		}
		
		private function timeLine2(event:TimerEvent):void
		{
			_timeLine2Timer.stop();
			_bufferTimer.stop();
			
			_currentTime = _stream.time - _timeShift;
			
			var caption:ASSCaption;
			var start:int = getTimer();
			
			for (var j:int; j < _captionsOnDisplay.length; j++)
			{
				if ((_captionsOnDisplay[j].isAnimated || _captionsOnDisplay[j].effects.COUNT > 0) && _currentTime < _captionsOnDisplay[j].event.endSeconds)
				{
					caption = _captionsOnDisplay.splice(j, 1)[0];
					//caption = _captionsOnDisplay[j];
					
					//renderer.remove(caption, _container);
					
					//caption = ASSCaption(renderer.render(captions, caption.event, _videoRect, _container, _stream.time, animated));
					renderer.render(captions, caption.event, _videoRect, _container, _stream.time, animated, caption);
					
					renderer.add(caption, Vector.<ICaption>(_captionsOnDisplay), _container, true);
					
					_captionsOnDisplay.push(caption);
					
					if (32 > (getTimer() - start)) break;
				}
			}
			
			_bufferTimer.start();
			_timeLine2Timer.start();
		}
		
		/**
		 * Starts the internal timer and buffer of the timeline.
		 */
		public function start():void
		{
			_captionsEnabled = true;
			
			_bufferTimer.start();
			_timeLineTimer.start();
			_timeLine2Timer.start();
		}
		
		/**
		 * Pauses (stops) the internal timer and buffer of the timeline.
		 */
		public function pause():void
		{
			_captionsEnabled = false;
			
			_bufferTimer.stop();
			_timeLineTimer.stop();
			_timeLine2Timer.stop();
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
			
			time = (time > -1 ? time : _stream.time - BUFFER_LENGTH);
			
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
	}
}
