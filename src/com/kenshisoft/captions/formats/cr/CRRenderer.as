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

package com.kenshisoft.captions.formats.cr
{
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	
	import com.kenshisoft.captions.enums.SubtitleEffect;
	import com.kenshisoft.captions.formats.ICaption;
	import com.kenshisoft.captions.formats.IParser;
	import com.kenshisoft.captions.formats.IRenderer;
	import com.kenshisoft.captions.formats.ass.ASSAnimOptions;
	import com.kenshisoft.captions.formats.ass.ASSEffect;
	import com.kenshisoft.captions.loaders.FontLoader;
	import com.kenshisoft.captions.misc.Util;
	import com.kenshisoft.captions.models.IEvent;
	import com.kenshisoft.captions.models.ISubtitle;
	import com.kenshisoft.captions.models.cr.CREvent;
	import com.kenshisoft.captions.models.cr.CRStyle;
	import com.kenshisoft.captions.models.cr.CRSubtitleScript;
	
	/**
	 * ...
	 * @author 
	 */
	public class CRRenderer implements IRenderer
	{
		private var _parser:CRParser;
		
		private var defaultHeight:int = 480;
		//private var staticMultiplier:int = 2; // orig
		private var calcHeight:Number;
		private var calcWidth:Number;
		
		public static const BOTTOM:String = TextFormatAlign.END;
		public static const MIDDLE:String = TextFormatAlign.JUSTIFY;
		public static const TOP:String = TextFormatAlign.START;
		public static const LEFT:String = TextFormatAlign.LEFT;
		public static const CENTER:String = TextFormatAlign.CENTER;
		public static const RIGHT:String = TextFormatAlign.RIGHT;
		
		public static const BOTTOM_LEFT:Array = [1, 1, BOTTOM, LEFT];
		public static const BOTTOM_CENTER:Array = [2, 2, BOTTOM, CENTER];
		public static const BOTTOM_RIGHT:Array = [3, 3, BOTTOM, RIGHT];
        public static const MIDDLE_LEFT:Array = [4, 9, MIDDLE, LEFT];
        public static const MIDDLE_CENTER:Array = [5, 10, MIDDLE, CENTER];
		public static const MIDDLE_RIGHT:Array = [6, 11, MIDDLE, RIGHT];
		public static const TOP_LEFT:Array = [7, 5, TOP, LEFT];
        public static const TOP_CENTER:Array = [8, 6, TOP, CENTER];
        public static const TOP_RIGHT:Array = [9, 7, TOP, RIGHT];
		
		public static const WRAP1:Array = [0, true, true];
        public static const WRAP2:Array = [1, true, true];
        public static const NONE:Array = [2, false, false];
		public static const WRAP3:Array = [3, true, true];
        
		public function CRRenderer()
		{
			super();
			
			_parser = new CRParser();
		}
		
		private function getGlowStrength(styleOutline:Number):Number
		{
            switch (styleOutline)
            {
				case 0:
					return 1;
				case 1:
					return 4;
				case 3:
					return 14;
				case 4:
                    return 28;
				case 2:
				default:
					return 7;
            }
        }
		
		private function getFilters(style:CRStyle):Array
		{
			var filters:Array = new Array();
            
            if (style.border_style != 1)
                return filters;
            
            var glowStrength:Number = getGlowStrength(style.outline);
            if (style.outline > 0)
                filters.push(new GlowFilter(Util.removeAlpha(style.colours[2]), 1, style.outline, style.outline, glowStrength, BitmapFilterQuality.HIGH));
			
            if (style.shadow > 0)
            {
				var dropShadow:DropShadowFilter = new DropShadowFilter();
                dropShadow.distance = style.shadow;
                dropShadow.color = Util.removeAlpha(Util.removeAlpha(style.colours[3]));
                filters.push(dropShadow);
            }
			
            return filters;
        }
		
		private function getAlignment(alignment:int):Array
		{
			var alignments:Array = [BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT, MIDDLE_LEFT, MIDDLE_CENTER, MIDDLE_RIGHT, TOP_LEFT, TOP_CENTER, TOP_RIGHT];
			
			for (var i:int; i < alignments.length; i++)
            {
                if (alignments[i][0] == alignment)
                    return alignments[i];
            }
			
            return null;
		}
		
		private function getStyleFormat(caption:CRCaption, style:CRStyle):TextFormat
		{
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = FontLoader.isFontRegistered("Embedded " + style.font_name) ? "Embedded " + style.font_name : style.font_name;
			textFormat.size = caption.scaleY * style.font_size;
			textFormat.color = Util.removeAlpha(style.colours[0]);
			textFormat.align = getAlignment(caption.alignment > 0 ? caption.alignment : style.alignment)[3];
			textFormat.bold = style.bold;
			textFormat.italic = style.italic;
			textFormat.underline = style.underline;
			textFormat.leftMargin = (caption.event.margin.left > 0 ? caption.event.margin.left : style.margin.left) - style.outline;
			textFormat.rightMargin = (caption.event.margin.right > 0 ? caption.event.margin.right : style.margin.right) - style.outline;
			
			return textFormat;
		}
		
		private function styleModifier(caption:CRCaption, tagsParsed:Vector.<Vector.<String>>, style:CRStyle, orgStyle:CRStyle, beginIndex:int, endIndex:int):CRStyle
		{
			var j:int; // inner loop index
			var d:Number; // dest
			var s:Number; // src
			var n:Number; // calculateAnimation result
			var e:ASSEffect;
			
			for (var i:int; i < tagsParsed.length; i++)
			{
				var tag:String = tagsParsed[i][0];
				var tagOptions:Vector.<String> = tagsParsed[i].slice(1);
				
				switch (tag)
				{
					case "an":
						d = Number(tagOptions[0]);
						if (caption.alignment < 0) caption.alignment = (d > 0 && d < 10) ? d : orgStyle.alignment;
						
						break;
					case "a":
						d = Number(tagOptions[0]);
						if (caption.alignment < 0) caption.alignment = (d > 0 && d < 12) ? ((((d - 1) & 3) + 1) + ((d & 4)?6:0) + ((d & 8)?3:0)) : orgStyle.alignment;
						
						break;
					case "b":
						d = Number(tagOptions[0]);
						style.bold = tagOptions[0].length > 0 ? (d == 0 ? false : d == 1 ? true : d >= 100 ? true : orgStyle.bold) : orgStyle.bold;
						
						break;
					case "c":
						if (tagOptions[0].length <= 0) { style.colours[0] = orgStyle.colours[0]; continue; }
						
						style.colours[0] = uint(tagOptions[0]);
						
						break;
					case "fade": // CR doesn't seem to use "fade" only "fad". leave it anyway
					case "fad":
						if (!caption.animOptions.animate) continue;
						
						if (tagOptions.length == 7 && !caption.effects.FADE) // {\fade(a1=param[0], a2=param[1], a3=param[2], t1=t[0], t2=t[1], t3=t[2], t4=t[3])}
						{
							e = new ASSEffect(SubtitleEffect.FADE);
							
							for (j = 0; j < 3; j++)
								e.param[i] = tagOptions[j];
							for (j = 0; j < 4; j++)
								e.t[j] = tagOptions[3+j];
							
							caption.effects.FADE = e;
							caption.effects.COUNT += 1;
						}
						else if (tagOptions.length == 2 && !caption.effects.FADE) // {\fad(t1=t[1], t2=t[2])}
						{
							e = new ASSEffect(SubtitleEffect.FADE);
							
							e.param[0] = e.param[2] = 0xff;
							e.param[1] = 0x00;
							for (j = 1; j < 3; j++)
								e.t[j] = tagOptions[j-1];
							e.t[0] = e.t[3] = -1; // will be substituted with "start" and "end"
							
							caption.effects.FADE = e;
							caption.effects.COUNT += 1;
						}
						
						break;
					case "fn":
						style.font_name = tagOptions[0].length > 0 ? tagOptions[0] : orgStyle.font_name;
						
						break;
					case "fs":
						if (tagOptions[0].length <= 0) { style.font_size = orgStyle.font_size; continue; }
						
						d = Number(tagOptions[0]);
						
						if (tagOptions[0].charAt(0) == '-' || tagOptions[0].charAt(0) == '+')
						{
							d = style.font_size + ((style.font_size * d) / 10);
							style.font_size = int(d > 0 ? d : orgStyle.font_size);
						}
						else
						{
							style.font_size = int(d > 0 ? d : orgStyle.font_size);
						}
						
						break;
					case "i":
						d = Number(tagOptions[0]);
						style.italic = tagOptions[0].length > 0 ? (d == 0 ? false : d == 1 ? true : orgStyle.italic) : orgStyle.italic;
						
						break;
					case "q":
						d = Number(tagOptions[0]);
						caption.wrapStyle = tagOptions[0].length > 0 && (0 <= d && d <= 3) ? d : caption.orgWrapStyle;
						
						break;
					case "u":
						d = Number(tagOptions[0]);
						style.underline = tagOptions[0].length > 0 ? (d == 0 ? false : d == 1 ? true : orgStyle.underline) : orgStyle.underline;
						
						break;
				}
			}
			
			caption.textField.setTextFormat(getStyleFormat(caption, style), beginIndex, endIndex);
			
			return style;
		}
		
		private function getWrapStyle(wrapStyle:int):Array
		{
			var wrapStyles:Array = [WRAP1, WRAP2, NONE, WRAP3];
			
			for (var i:int; i < wrapStyles.length; i++)
            {
                if (wrapStyles[i][0] == wrapStyle)
                    return wrapStyles[i];
            }
			
            return null;
		}
		
		private function getY(caption:CRCaption, style:CRStyle):Number
		{
			var t:int = ((caption.event.margin.bottom > 0 ? caption.event.margin.bottom : style.margin.bottom) * caption.scaleY) + style.outline;
			
            switch (getAlignment(caption.alignment > 0 ? caption.alignment : style.alignment)[2])
            {
				case TOP:
					//return t - staticMultiplier; // orig
					return t;
                case MIDDLE:
					return (calcHeight - caption.textField.textHeight) / 2;
				case BOTTOM:
                default:
                    //return (((calcHeight + staticMultiplier) - caption.textField.textHeight) - t) - caption.textField.getLineMetrics(0).descent; // orig
                    return ((calcHeight - caption.textField.textHeight) - t) - caption.textField.getLineMetrics(0).descent;
            }
        }
		
		private function getOpaqueBoxRect(caption:CRCaption, style:CRStyle):Rectangle
		{
            var metrics:TextLineMetrics = caption.textField.getLineMetrics(0);
			
            return new Rectangle(
				(caption.textField.x + (caption.event.margin.left > 0 ? caption.event.margin.left : style.margin.left)), 
				(caption.textField.y - style.outline), 
				((caption.textField.width - (caption.event.margin.left > 0 ? caption.event.margin.left : style.margin.left)) - (caption.event.margin.right > 0 ? caption.event.margin.right : style.margin.right)), 
				(((metrics.height * caption.textField.numLines) + (2 * style.outline)) + metrics.descent)
			);
        }
		
		private function createOpaqueBox(caption:CRCaption, style:CRStyle, renderSprite:Sprite):void
		{
			var rect:Rectangle = getOpaqueBoxRect(caption, style);
            var opaqueSprite:Sprite = new Sprite();
            
			opaqueSprite.x = caption.textField.x;
			opaqueSprite.y = caption.textField.y;
			
			opaqueSprite.graphics.beginFill(Util.removeAlpha(style.colours[3]), Util.getAlphaMultiplier(style.colours[3]));
			//opaqueSprite.graphics.drawRect(0, 0, rect.width, rect.height); // orig
			opaqueSprite.graphics.drawRect((caption.textField.width - rect.width)/2, 0, rect.width, rect.height);
			opaqueSprite.graphics.endFill();
			
            renderSprite.addChild(opaqueSprite);
		}
		
		private function applyEffects(caption:CRCaption, renderSprite:Sprite, videoRect:Rectangle, time:Number):void
		{
			var t:Number;
			var t1:int;
			var t2:int;
			var t3:int;
			var t4:int;
			
			var m_delay:Number = caption.event.duration * 1000;
			var m_time:Number = (time - caption.event.startSeconds) * 1000;
			
			for (var i:String in caption.effects)
			{
				if (caption.effects[i] == null || caption.effects[i] is int) continue;
				
				var effect:ASSEffect = caption.effects[i];
				
				switch (effect.type)
				{
					case SubtitleEffect.FADE:
						t1 = effect.t[0];
						t2 = effect.t[1];
						t3 = effect.t[2];
						t4 = effect.t[3];
						
						if (t1 == -1 && t4 == -1) { t1 = 0; t3 = m_delay - t3; t4 = m_delay; }
						
						if (m_time < t1) renderSprite.alpha = 1 - (effect.param[0] / 255);
						else if (m_time >= t1 && m_time < t2)
						{
							t = 1.0 * (m_time - t1) / (t2 - t1);
							renderSprite.alpha = 1 - (int(effect.param[0] * (1 - t) + effect.param[1] * t) / 255);
						}
						else if (m_time >= t2 && m_time < t3) renderSprite.alpha = 1 - (effect.param[1] / 255);
						else if (m_time >= t3 && m_time < t4)
						{
							t = 1.0 * (m_time - t3) / (t4 - t3);
							renderSprite.alpha = 1 - (int(effect.param[1] * (1 - t) + effect.param[2] * t) / 255);
						}
						else if (m_time >= t4) renderSprite.alpha = 1 - (effect.param[2] / 255);
						
						break;
				}
			}
		}
		
		public function render(subtitle_:ISubtitle, event_:IEvent, videoRect:Rectangle, container:DisplayObjectContainer, time:Number = -1, animate:Boolean = true, caption_:ICaption = null):ICaption
		{
			var subtitle:CRSubtitleScript = CRSubtitleScript(subtitle_);
			var event:CREvent = CREvent(event_);
			
			var orgStyle:CRStyle = _parser.getStyle(event.style, subtitle.styles);
			var style:CRStyle = orgStyle.copy();
			
			var caption:CRCaption = caption_ ? CRCaption(caption_) : new CRCaption(subtitle.wrap_style, style.alignment, event);
			
			if (caption_)
			{
				applyEffects(caption, caption.renderSprite, videoRect, time);
				
				return caption_;
			}
			
			caption.scaleX = subtitle.play_res_x > 0 ? (1.0 * videoRect.width / subtitle.play_res_x) : 1.0;
			caption.scaleY = subtitle.play_res_y > 0 ? (1.0 * videoRect.height / subtitle.play_res_y) : 1.0;
			
			caption.animOptions = new ASSAnimOptions((time - event.startSeconds) * 1000, event.duration * 1000, animate);
			
			//calcHeight = (subtitle.play_res_y > 0 ? subtitle.play_res_y : defaultHeight) * caption.scaleX; // orig
			calcHeight = videoRect.height;
			calcWidth = (Math.floor((calcHeight * videoRect.width) / videoRect.height));
			
			caption.textField = new TextField();
			caption.textField.filters = getFilters(style);
			caption.textField.defaultTextFormat = getStyleFormat(caption, style);
			caption.textField.height = calcHeight;
			//caption.textField.width = calcWidth + (2 * staticMultiplier); // orig
			caption.textField.width = calcWidth;
			//caption.textField.x = -staticMultiplier + videoRect.x; // orig
			caption.textField.x = videoRect.x;
			caption.textField.blendMode = BlendMode.LAYER;
			
			var str:String = event.text.replace(/\\N/g, '\n');
			
			var styleTextRegExp:RegExp = /\{([^\}]+)\}([^\{]*)|([^\{\}]+)/g;
			var match:Object = styleTextRegExp.exec(str);
			
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
				
				match = styleTextRegExp.exec(str);
			}
			
			caption.textField.wordWrap = getWrapStyle(caption.wrapStyle)[2];
            caption.textField.embedFonts = _parser.isFontEmbedded(style.font_name);
            if (!caption.textField.embedFonts)
			{
				caption.textField.sharpness = -100;
				caption.textField.gridFitType = GridFitType.NONE;
			}
			caption.textField.antiAliasType = AntiAliasType.ADVANCED;
			caption.textField.y = getY(caption, style) + videoRect.y;
			
			var renderSprite:Sprite = new Sprite();
			
			if (style.border_style == 0)
				createOpaqueBox(caption, style, renderSprite);
			
			applyEffects(caption, renderSprite, videoRect, time);
			
			renderSprite.addChild(caption.textField);
			
			renderSprite.cacheAsBitmap = true;
			caption.renderSprite = renderSprite;
			
			return caption;
		}
		
		public function add(caption_:ICaption, captionsOnDisplay_:Vector.<ICaption>, container:DisplayObjectContainer, rerender:Boolean = false):void
		{
			var caption:CRCaption = CRCaption(caption_);
			var captionsOnDisplay:Vector.<CRCaption> = Vector.<CRCaption>(captionsOnDisplay_);
			
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
