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

package com.kenshisoft.captions.formats.srt
{
	import com.kenshisoft.captions.formats.ICaption;
	import com.kenshisoft.captions.formats.IParser;
	import com.kenshisoft.captions.formats.IRenderer;
	import com.kenshisoft.captions.loaders.FontLoader;
	import com.kenshisoft.captions.misc.Size;
	import com.kenshisoft.captions.misc.Util;
	import com.kenshisoft.captions.models.IEvent;
	import com.kenshisoft.captions.models.ISubtitle;
	import com.kenshisoft.captions.models.srt.SRTEvent;
	import com.kenshisoft.captions.models.srt.SRTStyle;
	import com.kenshisoft.captions.models.srt.SRTSubtitle;
	
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author 
	 */
	public class SRTRenderer implements IRenderer// extends ASSRenderer
	{
		private var _parser:SRTParser;
		
		public function SRTRenderer()
		{
			super();
			
			_parser = new SRTParser();
		}
		
		private function getStyleFormat(caption:SRTCaption, style:SRTStyle):TextFormat
		{
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = style.fontName;
			textFormat.size = caption.scaleY * style.fontSize;
			textFormat.color = Util.removeAlpha(style.colours[0]);
			textFormat.align = TextFormatAlign.JUSTIFY; //FIXME:
			textFormat.bold = style.fontWeight;
			textFormat.italic = style.italic;
			textFormat.underline = style.underline;
			textFormat.leftMargin = style.marginRect.left;
			textFormat.rightMargin = style.marginRect.right;
			
			return textFormat;
		}
		
		private function styleModifier(caption:SRTCaption, tagsParsed:Vector.<Vector.<String>>, style:SRTStyle, orgStyle:SRTStyle, beginIndex:int, endIndex:int):SRTStyle
		{
			var j:int; // inner loop index
			var d:Number; // dest
			var s:Number; // src
			
			for (var i:int; i < tagsParsed.length; i++)
			{
				var tag:String = tagsParsed[i][0];
				var tagOptions:Vector.<String> = tagsParsed[i].slice(1);
				
				switch (tag)
				{
					case "b":
						d = Number(tagOptions[0]);
						style.fontWeight = tagOptions[0].length > 0 ? (d == 0 ? "normal" : d == 1 ? "bold" : d >= 100 ? "bold" : orgStyle.fontWeight) : orgStyle.fontWeight;
						
						break;
					case "i":
						d = Number(tagOptions[0]);
						style.italic = tagOptions[0].length > 0 ? (d == 0 ? "normal" : d == 1 ? "italic" : orgStyle.italic) : orgStyle.italic;
						
						break;
					case "u":
						d = Number(tagOptions[0]);
						style.underline = tagOptions[0].length > 0 ? (d == 0 ? "none" : d == 1 ? "underline" : orgStyle.underline) : orgStyle.underline;
						
						break;
				}
			}
			
			caption.textField.setTextFormat(getStyleFormat(caption, style), beginIndex, endIndex);
			
			return style;
		}
		
		public function render(subtitle_:ISubtitle, event_:IEvent, videoRect:Rectangle, container:DisplayObjectContainer, time:Number = -1, animate:Boolean = true, caption_:ICaption = null):ICaption
		{
			var subtitle:SRTSubtitle = SRTSubtitle(subtitle_);
			var event:SRTEvent = SRTEvent(event_);
			
			var orgStyle:SRTStyle = new SRTStyle();
			var style:SRTStyle = new SRTStyle();
			
			var caption:SRTCaption = new SRTCaption(event);
			
			var screenSize:Size = new Size(384, 288);
			
			caption.scaleX = screenSize.width > 0 ? (1.0 * (style.relativeTo == 1 ? videoRect.width : container.width) / screenSize.width) : 1.0;
			caption.scaleY = screenSize.height > 0 ? (1.0 * (style.relativeTo == 1 ? videoRect.height : container.height) / screenSize.height) : 1.0;
			
			caption.textField = new TextField();
			//caption.textField.filters = getFilters(style);
			caption.textField.defaultTextFormat = getStyleFormat(caption, style);
			//caption.textField.height = calcHeight;
			//caption.textField.width = calcWidth;
			caption.textField.x = videoRect.x;
			caption.textField.blendMode = BlendMode.LAYER;
			
			var styleTextRegExp:RegExp = /\{([^\}]+)\}([^\{]*)|([^\{\}]+)/g;
			var match:Object = styleTextRegExp.exec(event.text);
			
			var tmpStyleStr:String = '';
			var styleStr:String = '';
			var textStr:String = '';
			
			while (match != null)
			{
				tmpStyleStr = match[1] ? match[1] : '';
				if (textStr.length == 0) styleStr += tmpStyleStr; else styleStr = tmpStyleStr;
				textStr = (match[1] == null && match[2] == null) ? match[3] : match[2]; textStr = textStr ? textStr : "";
				
				var beginIndex:int = caption.textField.text.length - 1;
				caption.textField.text += textStr;
				
				if (styleStr.length > 0)
					style = styleModifier(caption, _parser.parseTag(styleStr), style, orgStyle, beginIndex, caption.textField.text.length - 1);
				
				match = styleTextRegExp.exec(event.text);
			}
			
			//caption.textField.wordWrap = getWrapStyle(caption.wrapStyle)[2];
			caption.textField.embedFonts = FontLoader.isFontRegistered(style.fontName);
			if (!caption.textField.embedFonts)
			{
				caption.textField.sharpness = -100;
				caption.textField.gridFitType = GridFitType.NONE;
			}
			caption.textField.antiAliasType = AntiAliasType.ADVANCED;
			//caption.textField.y = getY(caption, style) + videoRect.y;
			caption.textField.y = videoRect.bottom - caption.textField.height;
			
			var renderSprite:Sprite = new Sprite();
			renderSprite.addChild(caption.textField);
			
			renderSprite.cacheAsBitmap = true;
			caption.renderSprite = renderSprite;
			
			return caption;
		}
		
		public function add(caption_:ICaption, captionsOnDisplay_:Vector.<ICaption>, container:DisplayObjectContainer, rerender:Boolean = false):void
		{
			var caption:SRTCaption = SRTCaption(caption_);
			var captionsOnDisplay:Vector.<SRTCaption> = Vector.<SRTCaption>(captionsOnDisplay_);
			
			var insertAt:int = -1;
			
			for (var c:int; c < captionsOnDisplay.length; c++)
			{
				if (captionsOnDisplay[c].event.startSeconds > caption.event.startSeconds)
					try { insertAt = container.getChildIndex(captionsOnDisplay[c].renderSprite) - 1; } catch (error:Error) { }
			}
			
			try { insertAt == -1 ? container.addChild(caption.renderSprite) : container.addChildAt(caption.renderSprite, insertAt); } catch (error:Error) { }
		}
		
		public function remove(caption_:ICaption, container:DisplayObjectContainer):void
		{
			try { container.removeChild(caption_.renderSprite); } catch (error:Error) { }
		}
		
		public function get parser():IParser
		{
			return _parser;
		}
	}
}
