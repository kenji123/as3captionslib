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
	import fl.motion.Color;
	import flash.utils.ByteArray;
	
	public class Util
	{
		/*public static function copy(obj:Object):Object 
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(obj);
			bytes.position = 0;
			
			return bytes.readObject();
		}*/
		
		public static function toSeconds(str:String):Number
		{
			// assumes <hours>:<minutes>:<seconds>.<milliseconds> format
			var time:Array = str.replace(".", ":").split(":");
			
			var tl:int = time.length;
			for (var i:int = 0; i < tl; i++)
				time[i] = int(time[i]);
			
			return time.length < 4 ? -1 : ((((time[0]*60 + time[1])*60) + time[2]) + (time[3]/100));
		}
		
		public static function toColor(hexColour:String):Color
        {
			if (hexColour.indexOf("0x") >= 0)
				hexColour = hexColour.substr(hexColour.indexOf("0x"));
			
			while(hexColour.length < 8)
				hexColour = "0" + hexColour;
			
            var hexRegExp:RegExp = new RegExp("([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])", "i");
            var hexMatch:Object = hexRegExp.exec(hexColour);
			
            return hexMatch == null ? new Color() : new Color(1, 1, 1, 1, int("0x" + hexMatch[4]), int("0x" + hexMatch[3]), int("0x" + hexMatch[2]), int("0x" + hexMatch[1]));
        }
		
		public static function toDecimalColour(hexColour:String):Array
		{
			var bytes:Array = [];
			while (hexColour.length > 2)
			{
				var byte:String = hexColour.substr(-2);
				hexColour = hexColour.substr(0, hexColour.length-2);
				bytes.splice(0, 0, int("0x" + byte));
			}
			
			return bytes;
		}
		
		public static function toHexColour(decimalColour:*):String
		{
			var hexColour:String = "";
			
			if (decimalColour is String || decimalColour is Number || decimalColour is uint || decimalColour is int)
			{
				hexColour = (1*decimalColour).toString(16).toUpperCase();
			}
			else if (decimalColour is Color)
			{
				hexColour += decimalColour.redOffset.toString(16).toUpperCase();
				hexColour += decimalColour.greenOffset.toString(16).toUpperCase();
				hexColour += decimalColour.blueOffset.toString(16).toUpperCase();
				hexColour += decimalColour.alphaOffset.toString(16).toUpperCase();
			}
			else if (decimalColour is Array)
			{
				var dcl:int = decimalColour.length;
				for (var i:int = 0; i < dcl; i++)
					decimalColour[i] = decimalColour[i].toString(16).toUpperCase();
				
				hexColour = decimalColour.join();
			}
			
			while(hexColour.length < 8)
				hexColour = "0" + hexColour;
			
			return "0x" + hexColour;
		}
		
		public static function trim(str:String):String
		{
			if (str == null) return '';
			return str.replace(/^\s+|\s+$/g, '');
		}
		
		public static function trimLeft(str:String):String
		{
			if (str == null) return '';
			return str.replace(/^\s+/, '');
		}
		
		public static function trimRight(str:String):String
		{
			if (str == null) return '';
			return str.replace(/\s+$/, '');
		}
	}
}