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
	import com.kenshisoft.captions.enums.SubtitleMode;
	import com.kenshisoft.captions.misc.Size;
	
	public class ASSSubtitle
	{
		public static const SCRIPT_HEADER:String = ( <![CDATA[
											[Script Info]
										]]> ).toString();
		public static const STYLE_HEADER_SSA:String = ( <![CDATA[
											[V4 Styles]
                                    		Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, TertiaryColour, BackColour, Bold, Italic, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, AlphaLevel, Encoding
										]]> ).toString();
		public static const STYLE_HEADER_ASS:String = ( <![CDATA[
											[V4+ Styles]
                                    		Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
										]]> ).toString();
		public static const STYLE_HEADER_ASS_V6:String = ( <![CDATA[
											[V4++ Styles]
                                    		Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
										]]> ).toString();
		public static const EVENT_HEADER_SSA:String = ( <![CDATA[
											[Events]
                                    		Format: Marked, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
										]]> ).toString();
		public static const EVENT_HEADER_ASS:String = ( <![CDATA[
											[Events]
                                    		Format: Layer, Start, End, Style, Actor, MarginL, MarginR, MarginV, Effect, Text
										]]> ).toString();
		
		private var _mode:SubtitleMode = SubtitleMode.TIME;
		private var _screenSize:Size = new Size();
		private var _wrapStyle:int = 0;
		private var _collisions:int = 0;
		private var _scaledBorderAndShadow:Boolean = false;
		private var _scriptVersion:int = 5;
		private var _styleVersion:int = 5;
		private var _styles:Vector.<ASSStyle> = new Vector.<ASSStyle>;
    	private var _events:Vector.<ASSEvent> = new Vector.<ASSEvent>;
		
		// informational only
    	private var _title:String;
		private var _originalScript:String;
		private var _originalTranslation:String;
		private var _originalEditing:String;
		private var _originalTiming:String;
		private var _synchPoint:String;
		private var _scriptUpdatedBy:String;
		private var _updateDetails:String;
		private var _playDepth:String;
		private var _timer:Number;
		
		public function ASSSubtitle()
		{
			super();
		}
		
		public function get mode():SubtitleMode
        {
            return _mode;
		}
		
       	public function set mode(value:SubtitleMode):void
        {
            _mode = value;
		}
		
		public function get screenSize():Size
        {
            return _screenSize;
		}
		
       	public function set screenSize(value:Size):void
        {
            _screenSize = value;
		}
		
		public function get wrapStyle():int
        {
            return _wrapStyle;
		}
		
       	public function set wrapStyle(value:int):void
        {
            _wrapStyle = value;
		}
		
		public function get collisions():int
        {
            return _collisions;
		}
		
       	public function set collisions(value:int):void
        {
            _collisions = value;
		}
		
		public function get scaledBorderAndShadow():Boolean
        {
            return _scaledBorderAndShadow;
		}
		
       	public function set scaledBorderAndShadow(value:Boolean):void
        {
            _scaledBorderAndShadow = value;
		}
		
		public function get scriptVersion():int
        {
            return _scriptVersion;
		}
		
       	public function set scriptVersion(value:int):void
        {
            _scriptVersion = value;
		}
		
		public function get styleVersion():int
        {
            return _scriptVersion;
		}
		
       	public function set styleVersion(value:int):void
        {
            _scriptVersion = value;
		}
		
		public function get styles():Vector.<ASSStyle>
        {
            return _styles;
		}
		
       	public function set styles(value:Vector.<ASSStyle>):void
        {
            _styles = value;
		}
		
		public function get events():Vector.<ASSEvent>
        {
            return _events;
		}
		
       	public function set events(value:Vector.<ASSEvent>):void
        {
            _events = value;
		}
		
   		public function get title():String
        {
            return _title;
		}
		
       	public function set title(value:String):void
        {
            _title = value;
		}
		
		public function get originalScript():String
        {
            return _originalScript;
		}
		
       	public function set originalScript(value:String):void
        {
            _originalScript = value;
		}
		
		public function get originalTranslation():String
        {
            return _originalTranslation;
		}
		
       	public function set originalTranslation(value:String):void
        {
            _originalTranslation = value;
		}
		
		public function get originalEditing():String
        {
            return _originalEditing;
		}
		
       	public function set originalEditing(value:String):void
        {
            _originalEditing = value;
		}
		
		public function get originalTiming():String
        {
            return _originalTiming;
		}
		
       	public function set originalTiming(value:String):void
        {
            _originalTiming = value;
		}
		
		public function get synchPoint():String
        {
            return _synchPoint;
		}
		
       	public function set synchPoint(value:String):void
        {
            _synchPoint = value;
		}
		
		public function get scriptUpdatedBy():String
        {
            return _scriptUpdatedBy;
		}
		
       	public function set scriptUpdatedBy(value:String):void
        {
            _scriptUpdatedBy = value;
		}
		
		public function get updateDetails():String
        {
            return _updateDetails;
		}
		
       	public function set updateDetails(value:String):void
        {
            _updateDetails = value;
		}
		
		public function get playDepth():String
        {
            return _playDepth;
		}
		
       	public function set playDepth(value:String):void
        {
            _playDepth = value;
		}
		
		public function get timer():Number
        {
            return _timer;
		}
		
       	public function set timer(value:Number):void
        {
            _timer = value;
		}
	}
}