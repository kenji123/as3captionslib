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

package com.kenshisoft.captions.misc
{
	public class Util
	{
		public static function toSeconds(str:String):Number
		{
			// assumes <hours>:<minutes>:<seconds>[.|,]<milliseconds> format
			var time:Array = str.replace(/(\.|,)/, ":").split(":");
			
			while (time[3].length < 3)
				time[3] += "0";
			
			var tl:int = time.length;
			for (var i:int = 0; i < tl; i++)
				time[i] = int(time[i]);
			
			return time.length < 4 ? -1 : ((((time[0]*60 + time[1])*60) + time[2]) + (time[3]/1000));
		}
		
		public static function toHexColor2(color:uint, alpha:Boolean = true):String
		{
			var hexColor:String = color.toString(16).toUpperCase();
			
			while(hexColor.length < (alpha ? 8 : 6))
				hexColor = "0" + hexColor;
			
			return "0x" + hexColor;
		}
		
		public static function invertColor(color:uint, alpha:Boolean = true):uint
		{
			var hexColor:String = color.toString(16).toUpperCase();
			
			while(hexColor.length < (alpha ? 8 : 6))
				hexColor = "0" + hexColor;
			
			if (!alpha && hexColor.length > 6)
				while(hexColor.length > 6)
					hexColor = hexColor.substr(1);
			
			var argb:uint = 0;
			
			if (alpha)
				argb = uint("0x" + hexColor.substring(0, 2) + hexColor.substring(6, 8) + hexColor.substring(4, 6) + hexColor.substring(2, 4));
			else
				argb = uint("0x" + hexColor.substring(4, 6) + hexColor.substring(2, 4) + hexColor.substring(0, 2));
			
			return argb;
		}
		
		public static function removeAlpha(color:uint):uint
		{
			var hexColor:String = color.toString(16).toUpperCase();
			
			while(hexColor.length < 8)
				hexColor = "0" + hexColor;
			
			hexColor = hexColor.substr(2);
			
			return uint("0x" + hexColor);
		}
		
		public static function getAlphaMultiplier(color:uint):Number
		{
			return 1 - uint(color >> 24) / 255;
		}
		
		public static function trim(str:String):String
		{
			if (str == null) return '';
			return str.replace(/^\s+|\s+$/g, '');
		}
		
		/*public static function trimLeft(str:String):String
		{
			if (str == null) return '';
			return str.replace(/^\s+/, '');
		}
		
		public static function trimRight(str:String):String
		{
			if (str == null) return '';
			return str.replace(/\s+$/, '');
		}*/
	}
}
