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

package com.kenshisoft.captions.models.ass
{
	import com.kenshisoft.captions.misc.MarginRectangle;
	import com.kenshisoft.captions.misc.Util;
	
	public class ASSEvent
	{
		private var _layer:int = 0;
		private var _start:String = "00:00:00.00"; // stored as parsed. use startSeconds for numeric converted value
		private var _end:String = "00:00:05.00"; // stored as parsed. use endSeconds for numeric converted value
		private var _style:String = "Default";
		private var _actor:String = "";
		private var _marginRect:MarginRectangle = new MarginRectangle(20, 20, 20, 20);
		private var _effect:String = "";
		private var _text:String = "";
		
		// makes things easier when dealing with ass events
		private var _id:int;
		private var _startSeconds:Number;
		private var _endSeconds:Number;
		private var _duration:Number;
		
		public function ASSEvent()
		{
			super();
		}
		
		public function get layer():int
        {
            return _layer;
		}
		
       	public function set layer(value:int):void
        {
            _layer = value;
		}
		
		public function get start():String
        {
            return _start;
		}
		
       	public function set start(value:String):void
        {
            _start = value;
		}
		
    	public function get end():String
        {
            return _end;
		}
		
       	public function set end(value:String):void
        {
            _end = value;
		}
		
		public function get style():String
        {
            return _style;
		}
		
       	public function set style(value:String):void
        {
            _style = value;
		}
		
    	public function get actor():String
        {
            return _actor;
		}
		
       	public function set actor(value:String):void
        {
            _actor = value;
		}
		
    	public function get marginRect():MarginRectangle
		{
        	return _marginRect;
		}
		
        public function set marginRect(value:MarginRectangle):void
		{
            _marginRect = value;
		}
		
		public function get effect():String
		{
        	return _effect;
		}
		
        public function set effect(value:String):void
		{
            _effect = value;
		}
		
    	public function get text():String
		{
        	return _text;
		}
		
        public function set text(value:String):void
		{
            _text = value;
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
		
		public function copy():ASSEvent
		{
			var newEvent:ASSEvent = new ASSEvent();
			newEvent.layer = _layer;
			newEvent.start = _start;
			newEvent.end = _end;
			newEvent.style = _style;
			newEvent.actor = _actor;
			newEvent.marginRect = _marginRect.copy();
			newEvent.effect = _effect;
			newEvent.text = _text;
			newEvent.id = _id;
			newEvent.startSeconds = _startSeconds;
			newEvent.endSeconds = _endSeconds;
			newEvent.duration = _duration;
			
			return newEvent;
		}
	}
}