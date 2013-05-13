package com.kenshisoft.captions.formats.cr
{
	import com.kenshisoft.captions.FontClass;
	import com.kenshisoft.captions.formats.ICaption;
	import com.kenshisoft.captions.formats.IRenderer;
	import com.kenshisoft.captions.models.cr.CRSubtitleScript;
	import com.kenshisoft.captions.models.ISubtitle;
	import flash.geom.Rectangle;
	import flash.net.NetStream;
	import com.kenshisoft.captions.ICaptionsTimeLine;
	import flash.display.DisplayObjectContainer;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author 
	 */
	public class CRTimeLine implements ICaptionsTimeLine
	{
		private const BUFFER_LENGTH:int = 30; // buffer in seconds
		
		public var captions:CRSubtitleScript;
		public var renderer:CRRenderer;
		
		private var _animated:Boolean;
		public function get animated():Boolean { return _animated; };
		public function set animated(value:Boolean):void { _animated = value; };
		
		private var _timeShift:Number = 0;
		public function get timeShift():Number { return _timeShift; };
		public function set timeShift(value:Number):void { _timeShift = value; };
		
		private var _container:DisplayObjectContainer;
		private var _stream:NetStream;
		private var _videoRect:Rectangle;
		private var _captionsBuffer:Vector.<CRCaption> = new Vector.<CRCaption>;
		private var _captionsOnDisplay:Vector.<CRCaption> = new Vector.<CRCaption>;
		private var _captionsEnabled:Boolean = false;
		private var _bufferTimer:Timer;
		private var _timeLineTimer:Timer;
		private var _currentTime:Number = 0;
		private var _lastBufferIndex:int = 0;
		
		public var _captionDisplaySignal:Signal = new Signal(ICaption);
		public function get captionDisplaySignal():Signal { return _captionDisplaySignal; }
		
		public var _captionRemoveSignal:Signal = new Signal(ICaption);
		public function get captionRemoveSignal():Signal { return _captionRemoveSignal; }
		
		public function CRTimeLine(captions:ISubtitle, renderer:IRenderer, animated:Boolean)
		{
			super();
			
			this.captions = CRSubtitleScript(captions);
			this.renderer = CRRenderer(renderer);
			
			_animated = animated;
			
			_bufferTimer = new Timer(20);
			_bufferTimer.addEventListener(TimerEvent.TIMER, buffer);
			
			_timeLineTimer = new Timer(20);
			_timeLineTimer.addEventListener(TimerEvent.TIMER, timeLine);
		}
		
		private function buffer(event:TimerEvent):void 
		{
			_currentTime = _stream.time - _timeShift;
			
			for (var i:int = _lastBufferIndex; i < captions.events.length; i++)
			{
				if ((captions.events[i].startSeconds - _currentTime) < BUFFER_LENGTH)
				{
					_captionsBuffer.push(renderer.render(captions, captions.events[i], _videoRect, _container, captions.events[i].startSeconds, animated));
					
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
			_currentTime = _stream.time - _timeShift;
			
			var caption:CRCaption;
			var removedCaption:Boolean = false;
			
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
		
		public function start():void
		{
			_captionsEnabled = true;
			
			_bufferTimer.start();
			_timeLineTimer.start();
		}
		
		public function pause():void
		{
			_captionsEnabled = false;
			
			_bufferTimer.stop();
			_timeLineTimer.stop();
		}
		
		public function resume():void
		{
			start();
		}
		
		public function flushBuffer(time:Number = -1):void
		{
			_captionsBuffer = new Vector.<CRCaption>;
			
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
		
		private function flushDisplay():void
		{
			_captionsOnDisplay = new Vector.<CRCaption>;
			
			try
			{
				do
				{
					_container.removeChildAt(0);
				} while (_container.numChildren > 0);
			} catch (error:Error) { }
		}
		
		public function setContainer(container:DisplayObjectContainer):void
		{
			_container = container;
		}
		
		public function setStream(stream:NetStream):void
		{
			_stream = stream;
		}
		
		public function setVideoRect(videoRect:Rectangle):void
		{
			_videoRect = videoRect;
		}
	}
}
