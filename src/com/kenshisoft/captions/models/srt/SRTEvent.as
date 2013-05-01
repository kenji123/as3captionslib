package com.kenshisoft.captions.models.srt 
{
	import com.kenshisoft.captions.misc.MarginRectangle;
	import com.kenshisoft.captions.models.IEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class SRTEvent implements IEvent
	{
		private var _start:String;
		private var _end:String;
		private var _margin:MarginRectangle = new MarginRectangle(); // X1:left X2:right Y1:top Y2:bottom
		private var _text:String;
		
		private var _id:int;
		private var _startSeconds:Number;
		private var _endSeconds:Number;
		private var _duration:Number;
		
		public function SRTEvent()
		{
			super();
		}
		
		public function get id():int
        {
            return _id;
		}
		
       	public function set id(value:int):void
        {
            _id = value;
		}
		
		public function get startSeconds():Number
        {
            return _startSeconds;
		}
		
       	public function set startSeconds(value:Number):void
        {
            _startSeconds = value;
		}
		
		public function get endSeconds():Number
        {
            return _endSeconds;
		}
		
       	public function set endSeconds(value:Number):void
        {
            _endSeconds = value;
		}
		
		public function get duration():Number
        {
            return _duration;
		}
		
       	public function set duration(value:Number):void
        {
            _duration = value;
		}
	}
}
