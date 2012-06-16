/**
 * Copyright 2011-2012 Jamal Edey
 * 
 * This file is part of as3captionslib.
 * 
 * as3captionslib is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * as3captionslib is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with as3captionslib.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.kenshisoft.captions.misc
{
	import com.kenshisoft.captions.SubtitleWord;
	import com.kenshisoft.captions.misc.Position;
	
	/**
	 * ...
	 * @author ...
	 */
	public class VectorPosition
	{
		public static function getAt(pos:Position, vec:Vector.<SubtitleWord>):SubtitleWord
		{
			return vec[pos.index];
		}
		
		public static function getNext(pos:Position, vec:Vector.<SubtitleWord>):SubtitleWord
		{
			if ((pos.index + 1) >= vec.length)
			{
				pos.notNull = false;
				return vec[pos.index];
			}
			return vec[pos.index++];
		}
		
		public static function getPrevious(pos:Position, vec:Vector.<SubtitleWord>):SubtitleWord
		{
			if ((pos.index - 1) < 0)
			{
				pos.notNull = false;
				return vec[pos.index];
			}
			return vec[pos.index--];
		}
		
		public static function getHeadPosition(vec:Vector.<SubtitleWord>):Position
		{
			if (vec.length > 0)
				return new Position(0, true);
			else
				return new Position( -1, false);
		}
		
		public static function getCurrentPosition(pos:Position):Position
		{
			return new Position(pos.index, pos.notNull);
		}
		
		public static function getTailPosition(vec:Vector.<SubtitleWord>):Position
		{
			return new Position(vec.length - 1, false);
		}
	}
}