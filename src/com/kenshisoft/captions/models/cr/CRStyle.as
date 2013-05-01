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
	//import fl.motion.Color;
	
	import com.kenshisoft.captions.misc.MarginRectangle;
	import com.kenshisoft.captions.misc.Util;
	
	/**
	 * ...
	 * @author 
	 */
	public class CRStyle
	{
		private var _id:int;
		private var _name:String;
		private var _font_name:String;
		private var _font_size:Number;
		//private var _colours:Vector.<Color> = new Vector.<Color>; // primary, secondary, outline, back
		private var _colours:Vector.<uint> = new Vector.<uint>; // primary, secondary, outline, back
		private var _bold:int;
		private var _italic:int;
		private var _underline:int;
		private var _strikeout:int;
		private var _scale_x:Number;
		private var _scale_y:Number;
		private var _spacing:int;
		private var _angle:Number;
		private var _border_style:int;
		private var _outline:int;
		private var _shadow:int;
		private var _alignment:int;
		private var _margin:MarginRectangle = new MarginRectangle();
		private var _encoding:int;
		
		public function CRStyle()
		{
			super();
			
			//_colours.push(Util.toColor("0x00ffffff"), Util.toColor("0x0000ffff"), Util.toColor("0x00000000"), Util.toColor("0x80000000"));
		}
		
		public function get id():int
        {
            return _id;
		}
		
       	public function set id(value:int):void
        {
            _id = value;
		}
		
		public function get name():String
		{
        	return _name;
		}
		
        public function set name(value:String):void
		{
            _name = value;
		}
		
		public function get font_name():String
		{
        	return _font_name;
		}
		
        public function set font_name(value:String):void
		{
            _font_name = value;
		}
		
		public function get font_size():Number
		{
        	return _font_size;
		}
		
        public function set font_size(value:Number):void
		{
            _font_size = value;
		}
		
		//public function get colours():Vector.<Color>
		public function get colours():Vector.<uint>
		{
        	return _colours;
		}
		
        //public function set colours(value:Vector.<Color>):void
		public function set colours(value:Vector.<uint>):void
		{
            _colours = value;
		}
		
		public function get bold():int
		{
        	return _bold;
		}
		
        public function set bold(value:int):void
		{
            _bold = value;
		}
		
		public function get italic():int
		{
        	return _italic;
		}
		
        public function set italic(value:int):void
		{
            _italic = value;
		}
		
		public function get underline():int
		{
        	return _underline;
		}
		
        public function set underline(value:int):void
		{
            _underline = value;
		}
		
		public function get strikeout():int
		{
        	return _strikeout;
		}
		
        public function set strikeout(value:int):void
		{
            _strikeout = value;
		}
		
		public function get scale_x():Number
		{
        	return _scale_x;
		}
		
        public function set scale_x(value:Number):void
		{
            _scale_x = value;
		}
		
		public function get scale_y():Number
		{
        	return _scale_y;
		}
		
        public function set scale_y(value:Number):void
		{
            _scale_y = value;
		}
		
		public function get spacing():int
		{
        	return _spacing;
		}
		
        public function set spacing(value:int):void
		{
            _spacing = value;
		}
		
		public function get angle():Number
		{
        	return _angle;
		}
		
        public function set angle(value:Number):void
		{
            _angle = value;
		}
		
		public function get border_style():int
		{
        	return _border_style;
		}
		
        public function set border_style(value:int):void
		{
            _border_style = value;
		}
		
		public function get outline():int
		{
        	return _outline;
		}
		
        public function set outline(value:int):void
		{
            _outline = value;
		}
		
		public function get shadow():int
		{
        	return _shadow;
		}
		
        public function set shadow(value:int):void
		{
            _shadow = value;
		}
		
		public function get alignment():int
		{
        	return _alignment;
		}
		
        public function set alignment(value:int):void
		{
            _alignment = value;
		}
		
		public function get margin():MarginRectangle
		{
        	return _margin;
		}
		
        public function set margin(value:MarginRectangle):void
		{
            _margin = value;
		}
		
		public function get encoding():int
		{
        	return _encoding;
		}
		
        public function set encoding(value:int):void
		{
            _encoding = value;
		}
	}
}
