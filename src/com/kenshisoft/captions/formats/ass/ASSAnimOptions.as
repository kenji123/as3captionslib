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
	import com.kenshisoft.captions.FontClass;
	
	/**
	 * ...
	 * @author 
	 */
	public class ASSAnimOptions
	{
		public var time:Number;
		public var duration:Number;
		public var animate:Boolean;
		
		private var _animStart:int = 0;
		private var _animEnd:int = 0;
		private var _animAccel:Number = 1;
		private var _kType:int = 0;
		private var _kStart:int = 0;
		private var _kEnd:int = 0;
		private var _nPolygon:int = 0;
		private var _polygonBaselineOffset:int = 0;
		
		public function ASSAnimOptions(time:Number, duration:Number, animate:Boolean)
		{
			super();
			
			this.time = time;
			this.duration = duration;
			this.animate = animate;
		}
		
		public function get animStart():int
		{
			return _animStart;
		}
		
		public function set animStart(value:int):void
		{
			_animStart = value;
		}
		
		public function get animEnd():int
		{
			return _animEnd;
		}
		
		public function set animEnd(value:int):void
		{
			_animEnd = value;
		}
		
		public function get animAccel():Number
		{
			return _animAccel;
		}
		
		public function set animAccel(value:Number):void
		{
			_animAccel = value;
		}
		
		public function get kType():int
		{
			return _kType;
		}
		
		public function set kType(value:int):void
		{
			_kType = value;
		}
		
		public function get kStart():int 
		{
			return _kStart;
		}
		
		public function set kStart(value:int):void
		{
			_kStart = value;
		}
		
		public function get kEnd():int
		{
			return _kEnd;
		}
		
		public function set kEnd(value:int):void
		{
			_kEnd = value;
		}
		
		public function get nPolygon():int
		{
			return _nPolygon;
		}
		
		public function set nPolygon(value:int):void
		{
			_nPolygon = value;
		}
		
		public function get polygonBaselineOffset():int
		{
			return _polygonBaselineOffset;
		}
		
		public function set polygonBaselineOffset(value:int):void
		{
			_polygonBaselineOffset = value;
		}
	}
}
