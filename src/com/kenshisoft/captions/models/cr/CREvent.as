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

package com.kenshisoft.captions.models.cr 
{
	import com.kenshisoft.captions.misc.MarginRectangle;
	import com.kenshisoft.captions.models.IEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class CREvent implements IEvent
	{
		private var _id:int;
		private var _start:String;
		private var _end:String;
		private var _style:String;
		private var _name:String;
		private var _margin:MarginRectangle = new MarginRectangle();
		private var _effect:String;
		private var _text:String;
		
		// makes things easier when dealing with events
		private var _startSeconds:Number;
		private var _endSeconds:Number;
		private var _duration:Number;
		
		public function CREvent()
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
		
		public function get name():String
		{
        	return _name;
		}
		
        public function set name(value:String):void
		{
            _name = value;
		}
		
		public function get margin():MarginRectangle
		{
        	return _margin;
		}
		
        public function set margin(value:MarginRectangle):void
		{
            _margin = value;
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
