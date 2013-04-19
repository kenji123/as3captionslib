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
	/**
	 * ...
	 * @author 
	 */
	public class CRSubtitleScript
	{
		private var _id:int;
		private var _title:String;
		private var _play_res_x:int;
		private var _play_res_y:int;
		private var _lang_code:String;
		private var _lang_string:String;
		private var _created:String;
		private var _progress_string:String;
		private var _status_string:String;
		private var _wrap_style:int;
		
		public function CRSubtitleScript()
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
		
		public function get title():String
        {
            return _title;
		}
		
       	public function set title(value:String):void
        {
            _title = value;
		}
		
		public function get play_res_x():int
        {
            return _play_res_x;
		}
		
       	public function set play_res_x(value:int):void
        {
            _play_res_x = value;
		}
		
		public function get play_res_y():int
        {
            return _play_res_y;
		}
		
       	public function set play_res_y(value:int):void
        {
            _play_res_y = value;
		}
		
		public function get lang_code():String
        {
            return _lang_code;
		}
		
       	public function set lang_code(value:String):void
        {
            _lang_code = value;
		}
		
		public function get lang_string():String
        {
            return _lang_string;
		}
		
       	public function set lang_string(value:String):void
        {
            _lang_string = value;
		}
		
		public function get created():String
        {
            return _created;
		}
		
       	public function set created(value:String):void
        {
            _created = value;
		}
		
		public function get progress_string():String
        {
            return _progress_string;
		}
		
       	public function set progress_string(value:String):void
        {
            _status_string = value;
		}
		
		public function get status_string():String
        {
            return _status_string;
		}
		
       	public function set status_string(value:String):void
        {
            _status_string = value;
		}
		
		public function get wrap_style():int
        {
            return _wrap_style;
		}
		
       	public function set wrap_style(value:int):void
        {
            _wrap_style = value;
		}
	}
}
