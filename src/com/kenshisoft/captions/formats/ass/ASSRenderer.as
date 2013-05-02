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
	import com.kenshisoft.captions.formats.ICaption;
	import com.kenshisoft.captions.models.IEvent;
	import com.kenshisoft.captions.models.ISubtitle;
	//import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.text.FontStyle;
	import flash.text.FontType;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextRotation;
	
	import com.kenshisoft.captions.FontClass;
	import com.kenshisoft.captions.SubtitleWord;
	import com.kenshisoft.captions.enums.SubtitleEffect;
	import com.kenshisoft.captions.formats.IParser;
	import com.kenshisoft.captions.formats.IRenderer;
	import com.kenshisoft.captions.formats.ass.ASSCaption;
	import com.kenshisoft.captions.loaders.FontLoader;
	import com.kenshisoft.captions.misc.MarginRectangle;
	import com.kenshisoft.captions.misc.Size;
	import com.kenshisoft.captions.misc.Util;
	import com.kenshisoft.captions.models.ass.ASSEvent;
	import com.kenshisoft.captions.models.ass.ASSStyle;
	import com.kenshisoft.captions.models.ass.ASSSubtitle;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ASSRenderer implements IRenderer
	{
		private var _parser:ASSParser;
		
		public function ASSRenderer()
		{
			super();
			
			_parser = new ASSParser();
		}
		
		private function calculateAnimation(dst:Number, src:Number, isAnimated:Boolean, options:Object):Number
		{
			var s:int = options.animStart > 0 ? options.animStart : 0;
			var e:int = options.animEnd > 0 ? options.animEnd : options.duration;
			
			var ds:Number = dst - src;
			if((ds > 0 ? ds : -ds) >= 0.0001 && isAnimated)
			{
				if (options.time < s) dst = src;
				else if(s <= options.time && options.time < e)
				{
					var t:Number = Math.pow(1 * (options.time-s) / (e-s), options.animAccel);
					dst = (1-t) * src + t * dst;
				}
			}
			else
			{
				//dst = dst;
			}
			
			return dst;
		}
		
		private function styleModifier(caption:ASSCaption, tagsParsed:Vector.<Vector.<String>>, isAnimated:Boolean, style:ASSStyle, orgStyle:ASSStyle, styles:Vector.<ASSStyle>, options:Object):ASSStyle
		{
			var j:int; // inner loop index
			var d:*; // dest
			var s:*; // src
			var n:*; // calculateAnimation result
			var e:ASSEffect;
			
			for (var i:int; i < tagsParsed.length; i++)
			{
				var tag:String = tagsParsed[i][0];
				var tagOptions:Vector.<String> = tagsParsed[i].slice(1);
				
				switch (tag)
				{
					case "1c":
					case "2c":
					case "3c":
					case "4c":
						j = int(tag.charAt(0)) - 1;
						
						if (tagOptions[0].length <= 0) { style.colours[j] = orgStyle.colours[j]; continue; }
						
						d = uint(tagOptions[0]);
						/*s = Util.toHexColor(style.colours[j], false);
						
						style.colours[j] = Util.toColor((int(calculateAnimation(d & 0xff, s & 0xff, isAnimated, options)) & 0xff
							| int(calculateAnimation(d & 0xff00, s & 0xff00, isAnimated, options)) & 0xff00
							| int(calculateAnimation(d & 0xff0000, s & 0xff0000, isAnimated, options)) & 0xff0000).toString(16));*/
						s = style.colours[j];
						
						style.colours[j] = int(calculateAnimation(d & 0x00ff, s & 0x00ff, isAnimated, options)) & 0x00ff
							| int(calculateAnimation(d & 0x00ff00, s & 0x00ff00, isAnimated, options)) & 0x00ff00
							| int(calculateAnimation(d & 0x00ff0000, s & 0x00ff0000, isAnimated, options)) & 0x00ff0000;
						
						break;
					case "1a":
					case "2a":
					case "3a":
					case "4a":
						j = int(tag.charAt(0)) - 1;
						
						//if (tagOptions[0].length <= 0) { style.colours[j].alphaOffset = orgStyle.colours[j].alphaOffset; continue; }
						if (tagOptions[0].length <= 0) { style.colours[j] = (orgStyle.colours[j] >> 24) << 24 | Util.removeAlpha(orgStyle.colours[j]); continue; }
						
						//d = tagOptions[0];
						//style.colours[j].alphaOffset = int(calculateAnimation(d, style.colours[j].alphaOffset, isAnimated, options));
						style.colours[j] = int(calculateAnimation(uint(tagOptions[0]) << 24 | Util.removeAlpha(style.colours[j]), style.colours[j], isAnimated, options));
						
						break;
					case "alpha":
						for (j = 0; j < 4; j++)
							style.colours[j] = tagOptions[0].length > 0 ? int(calculateAnimation(uint(tagOptions[0]) << 24 | Util.removeAlpha(style.colours[j]), style.colours[j], isAnimated, options)) : (orgStyle.colours[j] >> 24) << 24 | Util.removeAlpha(orgStyle.colours[j]);
							//style.colours[j].alphaOffset = tagOptions[0].length > 0 ? int(calculateAnimation(d, style.colours[j].alphaOffset, isAnimated, options)) : orgStyle.colours[j].alphaOffset;
						
						break;
					case "an":
						d = Number(tagOptions[0]);
						if (caption.alignment < 0) caption.alignment = (d > 0 && d < 10) ? d : orgStyle.alignment;
						
						break;
					case "a":
						d = Number(tagOptions[0]);
						if (caption.alignment < 0) caption.alignment = (d > 0 && d < 12) ? ((((d - 1) & 3) + 1) + ((d & 4)?6:0) + ((d & 8)?3:0)) : orgStyle.alignment;
						
						break;
					case "blur":
						if (tagOptions[0].length <= 0) { style.gaussianBlur = orgStyle.gaussianBlur; continue; }
						
						n = calculateAnimation(Number(tagOptions[0]), style.gaussianBlur, isAnimated, options);
						style.gaussianBlur = n < 0 ? 0 : n;
						
						break;
					case "bord":
						if (tagOptions[0].length <= 0)
						{
							style.outlineWidthX = orgStyle.outlineWidthY;
							style.outlineWidthX = orgStyle.outlineWidthY;
							
							continue;
						}
						
						d = Number(tagOptions[0]);
						
						n = calculateAnimation(d, style.outlineWidthX, isAnimated, options);
						style.outlineWidthX = n < 0 ? 0 : n;
						
						n = calculateAnimation(d, style.outlineWidthY, isAnimated, options);
						style.outlineWidthY = n < 0 ? 0 : n;
						
						break;
					case "be":
						style.blur = tagOptions[0].length > 0 ? calculateAnimation(Number(tagOptions[0]), style.blur, isAnimated, options) : orgStyle.blur;
						
						break;
					case "b":
						d = Number(tagOptions[0]);
						style.fontWeight = tagOptions[0].length > 0 ? (d == 0 ? "normal" : d == 1 ? "bold" : d >= 100 ? "bold" : orgStyle.fontWeight) : orgStyle.fontWeight;
						
						break;
					case "clip":
					case "iclip": //TODO: write render code
						//TODO: style modifying code
						
						break;
					case "c":
						if (tagOptions[0].length <= 0) { style.colours[0] = orgStyle.colours[0]; continue; }
						
						d = uint(tagOptions[0]);
						/*s = Util.toHexColor(style.colours[0], false);
						
						style.colours[j] = Util.toColor((int(calculateAnimation(d & 0xff, s & 0xff, isAnimated, options)) & 0xff
							| int(calculateAnimation(d & 0xff00, s & 0xff00, isAnimated, options)) & 0xff00
							| int(calculateAnimation(d & 0xff0000, s & 0xff0000, isAnimated, options)) & 0xff0000).toString(16));*/
						s = style.colours[0];
						
						style.colours[j] = int(calculateAnimation(d & 0x00ff, s & 0x00ff, isAnimated, options)) & 0x00ff
							| int(calculateAnimation(d & 0x00ff00, s & 0x00ff00, isAnimated, options)) & 0x00ff00
							| int(calculateAnimation(d & 0x00ff0000, s & 0x00ff0000, isAnimated, options)) & 0x00ff0000;
						
						break;
					case "fade":
					case "fad":
						if (!options.animate) continue;
						
						if(tagOptions.length == 7 && !caption.effects.FADE) // {\fade(a1=param[0], a2=param[1], a3=param[2], t1=t[0], t2=t[1], t3=t[2], t4=t[3])}
						{
							e = new ASSEffect(SubtitleEffect.FADE);
							
							for(j = 0; j < 3; j++)
								e.param[i] = tagOptions[j];
							for(j = 0; j < 4; j++)
								e.t[j] = tagOptions[3+j];
							
							caption.effects.FADE = e;
							caption.effects.COUNT += 1;
						}
						else if(tagOptions.length == 2 && !caption.effects.FADE) // {\fad(t1=t[1], t2=t[2])}
						{
							e = new ASSEffect(SubtitleEffect.FADE);
							
							e.param[0] = e.param[2] = 0xff;
							e.param[1] = 0x00;
							for(j = 1; j < 3; j++) 
								e.t[j] = tagOptions[j-1];
							e.t[0] = e.t[3] = -1; // will be substituted with "start" and "end"
							
							caption.effects.FADE = e;
							caption.effects.COUNT += 1;
						}
						
						break;
					case "fe": //TODO: write render code
						style.charSet = tagOptions[0].length > 0 ? int(tagOptions[0]) : orgStyle.charSet;
						
						break;
					case "fn":
						style.fontName = _parser.getFontNameByAlias(tagOptions[0].length > 0 ? tagOptions[0] : orgStyle.fontName, options.fontInfo);
						_parser.setTrueFontHeight(style);
						
						break;
					case "frx":
						style.fontAngleX = tagOptions[0].length > 0 ? calculateAnimation(Number(tagOptions[0]), style.fontAngleX, isAnimated, options) : orgStyle.fontAngleX;
						
						break;
					case "fry":
						style.fontAngleY = tagOptions[0].length > 0 ? calculateAnimation(Number(tagOptions[0]), style.fontAngleY, isAnimated, options) : orgStyle.fontAngleY;
						
						break;
					case "frz":
					case "fr":
						style.fontAngleZ = tagOptions[0].length > 0 ? calculateAnimation(Number(tagOptions[0]), style.fontAngleZ, isAnimated, options) : orgStyle.fontAngleZ;
						
						break;
					case "fax":
						style.fontShiftX = caption.fax = tagOptions[0].length > 0 ? calculateAnimation(Number(tagOptions[0]), style.fontShiftX, isAnimated, options) : orgStyle.fontShiftX;
						
						break;
					case "fay":
						style.fontShiftY = caption.fay = tagOptions[0].length > 0 ? calculateAnimation(Number(tagOptions[0]), style.fontShiftY, isAnimated, options) : orgStyle.fontShiftY;
						
						break;
					case "fscx":
						if (tagOptions[0].length <= 0) { style.fontScaleX = orgStyle.fontScaleX; continue; }
						
						n = calculateAnimation(Number(tagOptions[0]), style.fontScaleX, isAnimated, options);
						style.fontScaleX = n < 0 ? 0 : n;
						
						break;
					case "fscy":
						if (tagOptions[0].length <= 0) { style.fontScaleY = orgStyle.fontScaleY; continue; }
						
						n = calculateAnimation(Number(tagOptions[0]), style.fontScaleY, isAnimated, options);
						style.fontScaleY = n < 0 ? 0 : n;
						
						break;
					case "fsc":
						style.fontScaleX = orgStyle.fontScaleX;
						style.fontScaleY = orgStyle.fontScaleY;
						
						break;
					case "fsp":
						if (tagOptions[0].length <= 0) { style.fontSpacing = orgStyle.fontSpacing; continue; }
						
						n = calculateAnimation(Number(tagOptions[0]), style.fontSpacing, isAnimated, options);
						style.fontSpacing = n < 0 ? 0 : n;
						
						break;
					case "fs":
						if (tagOptions[0].length <= 0) { style.fontSize = orgStyle.fontSize; style.orgFontSize = orgStyle.orgFontSize; continue; }
						
						d = Number(tagOptions[0]);
						
						if (tagOptions[0].charAt(0) == '-' || tagOptions[0].charAt(0) == '+')
						{
							n = calculateAnimation(style.orgFontSize + ((style.orgFontSize * d) / 10), style.orgFontSize, isAnimated, options);
							style.orgFontSize = n > 0 ? n : orgStyle.orgFontSize;
							_parser.setTrueFontHeight(style);
						}
						else
						{
							n = calculateAnimation(d, style.orgFontSize, isAnimated, options);
							style.orgFontSize = n > 0 ? n : orgStyle.orgFontSize;
							_parser.setTrueFontHeight(style);
						}
						
						break;
					case "i":
						d = Number(tagOptions[0]);
						style.italic = tagOptions[0].length > 0 ? (d == 0 ? "normal" : d == 1 ? "italic" : orgStyle.italic) : orgStyle.italic;
						
						break;
					case "kt": //TODO: write render code
						options.kStart = tagOptions[0].length > 0 ? Number(tagOptions[0]) * 10 : 0;
						options.kEnd = options.kStart;
						
						break;
					case "kf":
					case "K": //TODO: write render code
						options.kType = 1;
						options.kStart = options.kEnd;
						options.kEnd += tagOptions[0].length > 0 ? Number(tagOptions[0]) * 10 : 1000;
						
						break;
					case "ko": //TODO: write render code
						options.kType = 2;
						options.kStart = options.kEnd;
						options.kEnd += tagOptions[0].length > 0 ? Number(tagOptions[0]) * 10 : 1000;
						
						break;
					case "k": //TODO: write render code
						options.kType = 0;
						options.kStart = options.kEnd;
						options.kEnd += tagOptions[0].length > 0 ? Number(tagOptions[0]) * 10 : 1000;
						
						break;
					case "move": // {\move(x1=param[0], y1=param[1], x2=param[2], y2=param[3][, t1=t[0], t2=t[1]])}
						if((tagOptions.length == 4 || tagOptions.length == 6) && !caption.effects.MOVE)
						{
							e = new ASSEffect(SubtitleEffect.MOVE);
							
							e.param[0] = int(caption.scaleX * (options.animate ? int(tagOptions[0]) : int(tagOptions[2])));
							e.param[1] = int(caption.scaleY * (options.animate ? int(tagOptions[1]) : int(tagOptions[3])));
							e.param[2] = int(caption.scaleX * int(tagOptions[2]));
							e.param[3] = int(caption.scaleY * int(tagOptions[3]));
							
							e.t[0] = e.t[1] = -1;
							
							if(tagOptions.length == 6)
							{
								for(j = 0; j < 2; j++)
									e.t[j] = tagOptions[4+j];
							}
							
							caption.effects.MOVE = e;
							if (options.animate) caption.effects.COUNT += 1;
						}
						
						break;
					case "org": // {\org(x=param[0], y=param[1])}
						if(tagOptions.length == 2 && !caption.effects.ORG)
						{
							e = new ASSEffect(SubtitleEffect.ORG);
							
							e.param[0] = int(caption.scaleX * int(tagOptions[0]));
							e.param[1] = int(caption.scaleY * int(tagOptions[1]));
							
							caption.effects.ORG = e;
							if (options.animate) caption.effects.COUNT += 1;
						}
						
						break;
					case "pbo": //TODO: write render code
						options.polygonBaselineOffset = Number(tagOptions[0]);
						
						break;
					case "pos":
						if(tagOptions.length == 2 && !caption.effects.MOVE)
						{
							e = new ASSEffect(SubtitleEffect.MOVE);
							
							e.param[0] = e.param[2] = int(caption.scaleX * int(tagOptions[0]));
							e.param[1] = e.param[3] = int(caption.scaleY * int(tagOptions[1]));
							e.t[0] = e.t[1] = 0;
							
							caption.effects.MOVE = e;
						}
						
						break;
					case "p": //TODO: write render code
						n = Number(tagOptions[0]);
						options.nPolygon = n <= 0 ? 0 : n;
						
						break;
					case "q":
						d = Number(tagOptions[0]);
						caption.wrapStyle = tagOptions[0].length > 0 && (0 <= d && d <= 3) ? d : caption.orgWrapStyle;
						
						break;
					case "r":
						var newStyle:ASSStyle;
						if (tagOptions[0].length > 0) newStyle = _parser.getStyle(tagOptions[0], styles).copy();
						style = (newStyle != null) ? newStyle : orgStyle.copy();
						
						break;
					case "shad":
						if (tagOptions[0].length <= 0)
						{
							style.shadowDepthX = orgStyle.shadowDepthX;
							style.shadowDepthY = orgStyle.shadowDepthY;
							
							continue;
						}
						
						d = Number(tagOptions[0]);
						
						n = calculateAnimation(d, style.shadowDepthX, isAnimated, options);
						style.shadowDepthX = n < 0 ? 0 : n;
						
						n = calculateAnimation(d, style.shadowDepthY, isAnimated, options);
						style.shadowDepthY = n < 0 ? 0 : n;
						
						break;
					case "s":
						d = Number(tagOptions[0]);
						style.strikeOut = tagOptions[0].length > 0 ? (d == 0 ? false : d == 1 ? true : orgStyle.strikeOut) : orgStyle.strikeOut;
						
						break;
					case "t": // \t([<t1>,<t2>,][<accel>,]<style modifiers>)
						var p:*;
						
						options.animStart = options.animEnd = 0;
						options.animAccel = 1;
						
						if(tagOptions.length == 1)
						{
							p = tagOptions[0];
						}
						else if(tagOptions.length == 2)
						{
							options.animAccel = Number(tagOptions[0]);
							p = tagOptions[1];
						}
						else if(tagOptions.length == 3)
						{
							options.animStart = int(tagOptions[0]);
							options.animEnd = int(tagOptions[1]);
							p = tagOptions[2];
						}
						else if(tagOptions.length == 4)
						{
							options.animStart = int(tagOptions[0]); 
							options.animEnd = int(tagOptions[1]);
							options.animAccel = Number(tagOptions[2]);
							p = tagOptions[3];
						}
						
						style = styleModifier(caption, _parser.parseTag(p), options.animate, style, orgStyle, styles, options);
						
						caption.isAnimated = options.animate;
						
						break;
					case "u":
						d = Number(tagOptions[0]);
						style.underline = tagOptions[0].length > 0 ? (d == 0 ? "none" : d == 1 ? "underline" : orgStyle.underline) : orgStyle.underline;
						
						break;
					case "xbord":
						if (tagOptions[0].length <= 0) { style.outlineWidthX = orgStyle.outlineWidthX; continue; }
						
						n = calculateAnimation(Number(tagOptions[0]), style.outlineWidthX, isAnimated, options);
						style.outlineWidthX = n < 0 ? 0 : n;
						
						break;
					case "xshad":
						if (tagOptions[0].length <= 0) { style.shadowDepthX = orgStyle.shadowDepthX; continue; }
						
						style.shadowDepthX = calculateAnimation(Number(tagOptions[0]), style.shadowDepthX, isAnimated, options);
						
						break;
					case "ybord":
						if (tagOptions[0].length <= 0) { style.outlineWidthY = orgStyle.outlineWidthY; continue; }
						
						n = calculateAnimation(Number(tagOptions[0]), style.outlineWidthY, isAnimated, options);
						style.outlineWidthY = n < 0 ? 0 : n;
						
						break;
					case "yshad":
						if (tagOptions[0].length <= 0) { style.shadowDepthY = orgStyle.shadowDepthY; continue; }
						
						style.shadowDepthY = calculateAnimation(Number(tagOptions[0]), style.shadowDepthY, isAnimated, options);
						
						break;
				}
			}
			
			return style;
		}
		
		private function applyEffects(caption:ASSCaption, renderSprite:Sprite, videoRect:Rectangle, time:Number):void
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
					case SubtitleEffect.MOVE:
						var p:Point = new Point();
						var p1:Point = new Point(effect.param[0], effect.param[1]);
						var p2:Point = new Point(effect.param[2], effect.param[3]);
						t1 = effect.t[0];
						t2 = effect.t[1];
						
						if (t2 < t1) { t = t1; t1 = t2; t2 = t; }
						
						if (t1 <= 0 && t2 <= 0) { t1 = 0; t2 = m_delay; }
						
						if (m_time <= t1) p = p1;
						else if (p1 == p2) p = p1;
						else if (t1 < m_time && m_time < t2)
						{
							t = 1.0 * (m_time-t1) / (t2 - t1);
							p.x = (1 - t) * p1.x + t * p2.x;
							p.y = (1 - t) * p1.y + t * p2.y;
						}
						else p = p2;
						
						if (caption.relativeTo == 1)
						{
							p.x += videoRect.left;
							p.y += videoRect.top;
						}
						
						if (caption.alignment == 7 || caption.alignment == 4 || caption.alignment == 1)
							renderSprite.x = p.x;
						if (caption.alignment == 8 || caption.alignment == 5 || caption.alignment == 2)
							renderSprite.x = p.x - (caption.getRect().width / 2);
						if (caption.alignment == 9 || caption.alignment == 6 || caption.alignment == 3)
							renderSprite.x = p.x - caption.getRect().width;
						
						if (caption.alignment == 7 || caption.alignment == 8 || caption.alignment == 9)
							renderSprite.y = p.y;
						if (caption.alignment == 4 || caption.alignment == 5 || caption.alignment == 6)
							renderSprite.y = p.y - (caption.getRect().height / 2);
						if (caption.alignment == 1 || caption.alignment == 2 || caption.alignment == 3)
							renderSprite.y = p.y - caption.getRect().height;
						
						break;
					case SubtitleEffect.ORG:
						var op:Point = new Point(effect.param[0], effect.param[1]);
						var tp:Point = getTransformPoint(caption);
						
						if (caption.alignment == 7 || caption.alignment == 4 || caption.alignment == 1)
							op.x = op.x;
						if (caption.alignment == 8 || caption.alignment == 5 || caption.alignment == 2)
							op.x -= caption.getRect().width / 2;
						if (caption.alignment == 9 || caption.alignment == 6 || caption.alignment == 3)
							op.x -= caption.getRect().width;
						
						if (caption.alignment == 7 || caption.alignment == 8 || caption.alignment == 9)
							op.y = op.y;
						if (caption.alignment == 4 || caption.alignment == 5 || caption.alignment == 6)
							op.y -= caption.getRect().height / 2;
						if (caption.alignment == 1 || caption.alignment == 2 || caption.alignment == 3)
							op.y -= caption.getRect().height;
						
						if (caption.effects.MOVE != null)
						{
							//delete caption.effects[i];
							caption.effects[i] = null;
							applyEffects(caption, renderSprite, videoRect, time);
						}
						
						op.x = op.x - renderSprite.x;
						op.y = op.y - renderSprite.y;
						
						op.x = op.x > 0 ? op.x : -op.x;
						op.y = op.y > 0 ? op.y : -op.y;
						
						op.x = tp.x - op.x;
						op.y = tp.y - op.y;
						
						caption.transformPoint = op;
						
						break;
					case SubtitleEffect.BANNER:
						//TODO:
						
						break;
					case SubtitleEffect.SCROLL:
						//TODO:
						
						break;
				}
			}
		}
		
		private function isColliding(caption:ASSCaption, renderSprite:Sprite, cod:ASSCaption):Boolean
		{
			var r1:Rectangle = new Rectangle(cod.renderSprite.x, cod.renderSprite.y, cod.getRect().width, cod.getRect().height);
			var r2:Rectangle = new Rectangle(renderSprite.x, renderSprite.y, caption.getRect().width, caption.getRect().height);
			
			var xC:Boolean = false;
			var yC:Boolean = false;
			
			if (r1.left > r2.left && r1.right <= r2.right) xC = true;
			if (r1.left <= r2.left && r1.right > r2.left) xC = true;
			
			if (r1.top > r2.top && r1.bottom <= r2.bottom) yC = true;
			if (r1.top <= r2.top && r1.bottom > r2.top) yC = true;
			
			return xC && yC && (!cod.effects.MOVE && !cod.effects.ORG && !cod.effects.BANNER && !cod.effects.SCROLL && !cod.isAnimated) ? true : false;
		}
		
		private function handleCollisions(caption:ASSCaption, renderSprite:Sprite, captionsOnDisplay:Vector.<ASSCaption>, container:DisplayObjectContainer):void
		{
			var collisions:int = 0;
			var cod:ASSCaption;
			var noClashing:Boolean;
			var stackDown:Boolean = caption.alignment > 3;
			
			do
			{
				noClashing = true;
				
				for (var d:int; d < captionsOnDisplay.length; d++)
				{
					cod = captionsOnDisplay[d];
					
					if (collisions == 0) // stack on top currently displayed caption
					{
						if (caption.event.layer == cod.event.layer && isColliding(caption, renderSprite, cod))
						{
							if (stackDown)
								renderSprite.y = cod.renderSprite.y + cod.getRect().height;
							else
								renderSprite.y = cod.renderSprite.y - caption.getRect().height;
							
							noClashing = false;
						}
					}
					else // stack currently displayed caption on top the new caption
					{
						//TODO: NEVER!
					}
				}
			}
			while (!noClashing);
		}
		
		private function getTransformPoint(caption:ASSCaption):Point
		{
			var point:Point = new Point();
			
			if (caption.alignment == 7 || caption.alignment == 4 || caption.alignment == 1)
				point.x = 0;
			if (caption.alignment == 8 || caption.alignment == 5 || caption.alignment == 2)
				point.x = caption.getRect().width / 2;
			if (caption.alignment == 9 || caption.alignment == 6 || caption.alignment == 3)
				point.x = caption.getRect().width;
			
			if (caption.alignment == 7 || caption.alignment == 8 || caption.alignment == 9)
				point.y = caption.getRect().y;
			if (caption.alignment == 4 || caption.alignment == 5 || caption.alignment == 6)
				point.y = caption.getRect().height / 2;
			if (caption.alignment == 1 || caption.alignment == 2 || caption.alignment == 3)
				point.y = caption.getRect().height;
			
			return point;
		}
		
		public function renderText(text:String, style:ASSStyle, outline:Boolean = false, bodyShadow:Boolean = false, outlineShadow:Boolean = false):TextLine
		{
			var elementFormat:ElementFormat = new ElementFormat();
			elementFormat.fontDescription = new FontDescription(style.fontName, style.fontWeight, style.italic, (style.fontEmbed ? FontLookup.EMBEDDED_CFF : FontLookup.DEVICE));
			elementFormat.fontSize = style.fontSize;
			elementFormat.trackingLeft = elementFormat.trackingRight = style.fontSpacing / 2;
			elementFormat.textRotation = TextRotation.ROTATE_0;
			if (!outline && !bodyShadow && !outlineShadow)
			{
				/*elementFormat.color = style.colours[0].color;
				elementFormat.alpha = 1 - (style.colours[0].alphaOffset / 255);*/
				elementFormat.color = Util.invertColor(style.colours[0]);
				elementFormat.alpha = Util.getAlphaMultiplier(style.colours[0]);
			}
			else if (outline)
			{
				//elementFormat.color = style.colours[2].color;
				elementFormat.color = Util.invertColor(style.colours[2]);
				if ((style.outlineWidthX + style.outlineWidthY) > 0)
					elementFormat.alpha = Util.getAlphaMultiplier(style.colours[2]);
					//elementFormat.alpha = 1 - (style.colours[2].alphaOffset / 255);
				else
					elementFormat.alpha = 0;
			}
			else if (bodyShadow)
			{
				//elementFormat.color = style.colours[3].color;
				elementFormat.color = Util.invertColor(style.colours[3]);
				if (style.shadowDepthX != 0 || style.shadowDepthY != 0)
					elementFormat.alpha = Util.getAlphaMultiplier(style.colours[0]);
					//elementFormat.alpha = 1 - (style.colours[0].alphaOffset / 255);
				else
					elementFormat.alpha = 0;
			}
			else if (outlineShadow)
			{
				//elementFormat.color = style.colours[3].color;
				elementFormat.color = Util.invertColor(style.colours[3]);
				if ((style.outlineWidthX + style.outlineWidthY) > 0 && (style.shadowDepthX != 0 || style.shadowDepthY != 0))
					elementFormat.alpha = Util.getAlphaMultiplier(style.colours[2]);
					//elementFormat.alpha = 1 - (style.colours[2].alphaOffset / 255);
				else
					elementFormat.alpha = 0;
			}
			
			var textBlock:TextBlock = new TextBlock(new TextElement(text, elementFormat));
			var textLine:TextLine = textBlock.createTextLine();
			textBlock.releaseLineCreationData();
			
			return textLine;
		}
		
		private function renderBody(style:ASSStyle):Array
		{
			if ((style.outlineWidthX + style.outlineWidthY) > 0) return [];
			
			var gBlur:BlurFilter = new BlurFilter(style.gaussianBlur, style.gaussianBlur, BitmapFilterQuality.HIGH);
			var blur:BlurFilter = new BlurFilter(style.blur, style.blur, BitmapFilterQuality.LOW);
			
			return [gBlur, blur];
		}
		
		private function renderOutline(style:ASSStyle):Array
		{
			if ((style.outlineWidthX + style.outlineWidthY) <= 0) return [];
			
			var sb:Number = Math.sqrt(style.blur);
			var bl:Number = style.gaussianBlur > sb ? style.gaussianBlur : sb;
			
			var outlineColour:DropShadowFilter = new DropShadowFilter();
			outlineColour.quality = BitmapFilterQuality.HIGH;
			outlineColour.strength = style.gaussianBlur > 0 || style.blur > 0 ? bl + 4 : style.outlineWidthX * 10;
			outlineColour.blurX = style.outlineWidthX + bl;
			outlineColour.blurY = style.outlineWidthY + bl;
			outlineColour.distance = 0;
			/*outlineColour.color = style.colours[2].color;
			outlineColour.alpha = (1 - (style.colours[2].alphaOffset / 255));*/
			outlineColour.color = Util.invertColor(style.colours[2]);
			outlineColour.alpha = Util.getAlphaMultiplier(style.colours[2]);
			outlineColour.knockout = true;
			
			var gBlur:BlurFilter = new BlurFilter(style.gaussianBlur, style.gaussianBlur, BitmapFilterQuality.HIGH);
			var blur:BlurFilter = new BlurFilter(style.blur, style.blur, BitmapFilterQuality.LOW);
			
			return [outlineColour, gBlur, blur];
		}
		
		private function renderBodyShadow(style:ASSStyle):Array
		{
			if (style.shadowDepthX == 0 && style.shadowDepthY == 0) return [];
			
			var shadowColour:DropShadowFilter = new DropShadowFilter();
			shadowColour.quality = BitmapFilterQuality.HIGH;
			shadowColour.strength = 20;
			shadowColour.blurX = shadowColour.blurY = 0;
			shadowColour.distance = 0;
			/*shadowColour.color = style.colours[3].color;
			shadowColour.alpha = (1 - (style.colours[3].alphaOffset / 255));*/
			shadowColour.color = Util.invertColor(style.colours[3]);
			shadowColour.alpha = Util.getAlphaMultiplier(style.colours[3]);
			shadowColour.hideObject = true;
			
			var gBlur:BlurFilter = new BlurFilter(style.gaussianBlur, style.gaussianBlur, BitmapFilterQuality.HIGH);
			var blur:BlurFilter = new BlurFilter(style.blur, style.blur, BitmapFilterQuality.LOW);
			
			return [shadowColour, gBlur, blur];
		}
		
		private function renderOutlineShadow(style:ASSStyle):Array
		{
			var outlineColour:DropShadowFilter = new DropShadowFilter();
			outlineColour.quality = BitmapFilterQuality.HIGH;
			outlineColour.strength = style.outlineWidthX * 10;
			outlineColour.blurX = style.outlineWidthX;
			outlineColour.blurY = style.outlineWidthY;
			outlineColour.distance = 0;
			/*outlineColour.color = style.colours[3].color;
			outlineColour.alpha = (1 - (style.colours[3].alphaOffset / 255));*/
			outlineColour.color = Util.invertColor(style.colours[3]);
			outlineColour.alpha = Util.getAlphaMultiplier(style.colours[3]);
			outlineColour.knockout = true;
			
			var gBlur:BlurFilter = new BlurFilter(style.gaussianBlur, style.gaussianBlur, BitmapFilterQuality.HIGH);
			var blur:BlurFilter = new BlurFilter(style.blur, style.blur, BitmapFilterQuality.LOW);
			
			return [outlineColour, gBlur, blur];
		}
		
		private function strikeOutUnderlineHack(ascent:int, style:ASSStyle, body:TextLine, outline:TextLine, bodyShadow:TextLine, outlineShadow:TextLine):void
		{
			var sRect:Rectangle = body.getAtomBounds(0);
			var eRect:Rectangle = body.getAtomBounds(body.atomCount - 1);
			
			var x1:Number = sRect.left;
			var y1:Number;
			
			var x2:Number = eRect.right;
			var y2:Number = 0;
			
			var thickness:Number;
			
			if (style.strikeOut)
			{
				y1 = body.textBlock.content.elementFormat.getFontMetrics().strikethroughOffset;
				thickness = body.textBlock.content.elementFormat.getFontMetrics().strikethroughThickness;
				
				var bodyStrike:Shape = renderStrikeOutUnderline(x1, y1, x2, y2, thickness, style);
				var outlineStrike:Shape = renderStrikeOutUnderline(x1, y1, x2, y2, thickness, style, true);
				var bodyShadowStrike:Shape = renderStrikeOutUnderline(x1, y1, x2, y2, thickness, style, false, true);
				var outlineShadowStrike:Shape = renderStrikeOutUnderline(x1, y1, x2, y2, thickness, style, false, false, true);
				
				outlineShadow.addChild(outlineShadowStrike);
				bodyShadow.addChild(bodyShadowStrike);
				outline.addChild(outlineStrike);
				body.addChild(bodyStrike);
			}
			
			if (style.underline == "underline")
			{
				y1 = body.textBlock.content.elementFormat.getFontMetrics().underlineOffset;
				thickness = body.textBlock.content.elementFormat.getFontMetrics().underlineThickness;
				
				var bodyUnderline:Shape = renderStrikeOutUnderline(x1, y1, x2, y2, thickness, style);
				var outlineUnderline:Shape = renderStrikeOutUnderline(x1, y1, x2, y2, thickness, style, true);
				var bodyShadowUnderline:Shape = renderStrikeOutUnderline(x1, y1, x2, y2, thickness, style, false, true);
				var outlineShadowUnderline:Shape = renderStrikeOutUnderline(x1, y1, x2, y2, thickness, style, false, false, true);
				
				outlineShadow.addChild(outlineShadowUnderline);
				bodyShadow.addChild(bodyShadowUnderline);
				outline.addChild(outlineUnderline);
				body.addChild(bodyUnderline);
			}
		}
		
		private function renderStrikeOutUnderline(x1:Number, y1:Number, x2:Number, y2:Number, thickness:Number, style:ASSStyle, outline:Boolean = false, bodyShadow:Boolean = false, outlineShadow:Boolean = false):Shape
		{
			var color:uint = 0;
			var alpha:Number;
			
			if (!outline && !bodyShadow && !outlineShadow)
			{
				//color = style.colours[0].color;
				//alpha = 1 - (style.colours[0].alphaOffset / 255);
				color = Util.invertColor(style.colours[0]);
				alpha = Util.getAlphaMultiplier(style.colours[0]);
			}
			else if (outline)
			{
				//color = style.colours[2].color;
				color = Util.invertColor(style.colours[2]);
				if ((style.outlineWidthX + style.outlineWidthY) > 0)
					alpha = Util.getAlphaMultiplier(style.colours[2]);
					//alpha = 1 - (style.colours[2].alphaOffset / 255);
				else
					alpha = 0;
			}
			else if (bodyShadow)
			{
				//color = style.colours[3].color;
				color = Util.invertColor(style.colours[3]);
				if ((style.outlineWidthX + style.outlineWidthY) > 0)
					alpha = Util.getAlphaMultiplier(style.colours[0]);
					//alpha = 1 - (style.colours[0].alphaOffset / 255);
				else
					alpha = 0;
			}
			else if (outlineShadow)
			{
				//color = style.colours[3].color;
				color = Util.invertColor(style.colours[3]);
				if ((style.outlineWidthX + style.outlineWidthY) > 0 && (style.shadowDepthX != 0 || style.shadowDepthY != 0))
					alpha = Util.getAlphaMultiplier(style.colours[2]);
					//alpha = 1 - (style.colours[2].alphaOffset / 255);
				else
					alpha = 0;
			}
			
			var s:Shape = new Shape();
			s.x = x1;
			s.y = y1;
			//s.graphics.lineStyle((style.fontSize / 12.5), color, alpha);
			s.graphics.lineStyle(thickness, color, alpha);
			s.graphics.lineTo(x2, y2);
			
			return s;
		}
		
		private function getTransformPerspective(transformPoint:Point):PerspectiveProjection
		{
			var perspective:PerspectiveProjection = new PerspectiveProjection();
			perspective.fieldOfView = 110; //TODO: check. this value seems to work pretty well
			perspective.projectionCenter = transformPoint;
			
			return perspective;
		}
		
		private function transform(matrix3d:Matrix3D, transformPoint:Point, style:ASSStyle):Matrix3D
		{
			matrix3d.appendTranslation( -transformPoint.x, -transformPoint.y, -0);
			
			if (style.fontAngleX != 0) matrix3d.appendRotation( -style.fontAngleX, Vector3D.X_AXIS);
			if (style.fontAngleY != 0) matrix3d.appendRotation( -style.fontAngleY, Vector3D.Y_AXIS);
			if (style.fontAngleZ != 0) matrix3d.appendRotation( -style.fontAngleZ, Vector3D.Z_AXIS);
			
			matrix3d.appendTranslation(transformPoint.x, transformPoint.y, 0);
			
			return matrix3d;
		}
		
		private function italicHack(matrix3d:Matrix3D, style:ASSStyle):Matrix3D
		{
			var rawData:Vector.<Number> = matrix3d.rawData;
			try
			{
				rawData[4] = -0.2;
				matrix3d.rawData = rawData;
			}
			catch (error:Error)
			{
				// matrix probably doesn't have an identity
				trace(error.getStackTrace().toString());
			}
			
			return matrix3d;
		}
		
		public function render(subtitle_:ISubtitle, event_:IEvent, videoRect:Rectangle, container:DisplayObjectContainer, fontClasses:Vector.<FontClass>, time:Number = -1, animate:Boolean = true):ICaption
		{
			var subtitle:ASSSubtitle = ASSSubtitle(subtitle_);
			var event:ASSEvent = ASSEvent(event_);
			
			var style:ASSStyle = _parser.getStyle(event.style, subtitle.styles).copy();
			var orgStyle:ASSStyle = _parser.getStyle(event.style, subtitle.styles);
			
			var caption:ASSCaption = new ASSCaption(subtitle.wrapStyle, style.alignment, event);
			if (!caption) return null;
			
			caption.relativeTo = style.relativeTo;
			
			caption.scaleX = subtitle.screenSize.width > 0 ? (1.0 * (style.relativeTo == 1 ? videoRect.width : container.width) / subtitle.screenSize.width) : 1.0;
			caption.scaleY = subtitle.screenSize.height > 0 ? (1.0 * (style.relativeTo == 1 ? videoRect.height : container.height) / subtitle.screenSize.height) : 1.0;
			
			var options:Object = new Object();
			options.time = (time - event.startSeconds) * 1000;
			options.duration = event.duration * 1000;
			options.fontInfo = fontClasses;
			options.animate = animate;
			
			options.animStart = options.animEnd = 0;
			options.animAccel = 1;
			options.kType = options.kStart = options.kEnd = 0;
			options.nPolygon = 0;
			options.polygonBaselineOffset = 0;
			
			if (animate) _parser.parseEffect(caption, event.effect);
			
			var str:String = event.text;
			
			while (str.length > 0)
			{
				var i:int;
				
				if(str.charAt(0) == '{' && (i = str.indexOf('}')) > 0)
				{
					style = styleModifier(caption, _parser.parseTag(str.substr(1, i-1)), false, style, orgStyle, subtitle.styles, options);
					
					str = str.substr(i+1);
				}
				
				i = str.indexOf('{');
				if(i < 0) i = str.length;
				if(i == 0) continue;
				
				var tmp:ASSStyle = style.copy();
				tmp.fontSize = caption.scaleY * tmp.fontSize;
				tmp.fontSpacing = caption.scaleX * tmp.fontSpacing;
				tmp.outlineWidthX *= subtitle.scaledBorderAndShadow ? caption.scaleX : 1;
				tmp.outlineWidthY *= subtitle.scaledBorderAndShadow ? caption.scaleY : 1;
				tmp.shadowDepthX *= subtitle.scaledBorderAndShadow ? caption.scaleX : 1;
				tmp.shadowDepthY *= subtitle.scaledBorderAndShadow ? caption.scaleY : 1;
				
				if (options.nPolygon > 0)
					_parser.parsePolygon(caption, str.substr(0, i), tmp);
				else
					_parser.parseString(caption, str.substr(0, i), tmp, this);
				
				str = str.substr(i);
			}
			
			// RTS.cpp: just a "work-around" solution... in most cases nobody will want to use \org together with moving but without rotating the subs
			/*if (caption.effects.ORG && (caption.effects.MOVE || caption.effects.BANNER || caption.effects.SCROLL))
				caption.isAnimated = true;*/
			
			if(caption.alignment < 0) caption.alignment = (caption.alignment > 0 ? caption.alignment : -caption.alignment);
			
			var marginRect:MarginRectangle = event.marginRect.copy();
			if(marginRect.left == 0) marginRect.left = orgStyle.marginRect.left;
			if(marginRect.top == 0) marginRect.top = orgStyle.marginRect.top;
			if(marginRect.right == 0) marginRect.right = orgStyle.marginRect.right;
			if(marginRect.bottom == 0) marginRect.bottom = orgStyle.marginRect.bottom;
			marginRect.left = caption.scaleX * marginRect.left;
			marginRect.top = caption.scaleY * marginRect.top;
			marginRect.right = caption.scaleX * marginRect.right;
			marginRect.bottom = caption.scaleY * marginRect.bottom;
			
			if(caption.relativeTo == 1)
			{
				marginRect.left += videoRect.left;
				marginRect.top += videoRect.top;
				marginRect.right += container.width - videoRect.right;
				marginRect.bottom += container.height - videoRect.bottom;
			}
			
			// though only marginRect.width is used/needed once, store both anyway
			marginRect.width = container.width - (marginRect.left + marginRect.right);
			marginRect.height = container.height - (marginRect.top + marginRect.bottom);
			
			//TODO: (clip/iclip)ers
			//sub->m_clip.SetRect(0, 0, m_size.cx>>3, m_size.cy>>3);
			
			caption.makeLines(marginRect);
			
			var renderSprite:Sprite = new Sprite();
			
			// apply fax/fay transform (first occurance is absolute, and cannot be turned off using \r)
			// method 1
			/*renderSprite.transform.matrix3D = new Matrix3D();
			var matrix3d:Matrix3D = renderSprite.transform.matrix3D.clone();
			var rawData:Vector.<Number> = matrix3d.rawData;
			try
			{
				rawData[4] += caption.fax;
				rawData[1] += caption.fay;
				matrix3d.rawData = rawData;
			}
			catch (error:Error)
			{
				// matrix probably doesn't have an identity
				trace(error.getStackTrace().toString());
			}
			renderSprite.transform.matrix3D = matrix3d;*/
			
			// method 2
			var matrix:Matrix = renderSprite.transform.matrix.clone();
			matrix.c += caption.fax;
			matrix.b += caption.fay;
			renderSprite.transform.matrix = matrix;
			
			renderSprite.name = caption.event.id.toString();
			renderSprite.x = caption.getRect().x;
			renderSprite.y = caption.getRect().y;
			
			applyEffects(caption, renderSprite, videoRect, time);
			
			// let's get the point
			if (caption.transformPoint == null)
				caption.transformPoint = getTransformPoint(caption);
			
			var rendered:Vector.<Vector.<TextLine>> = new Vector.<Vector.<TextLine>>;
			
			for (var l:int; l < caption.lines.length; l++)
			{
				var firstWord:Boolean = true;
				var lastWordXWidth:Number = 0;
				
				// let's render line by line
				for (var w:int = 0; w < caption.lines[l].words.length; w++)
				{
					var word:SubtitleWord = caption.lines[l].words[w];
					var bodyOnly:Boolean = ((word.isWhiteSpace || word.isLineBreak) && !style.strikeOut && !word.style.underline == "underline")
					
					// render
					var body:TextLine = word.textLine;
					var outline:TextLine = bodyOnly ? null : renderText(word.text, word.style, true);
					var bodyShadow:TextLine = bodyOnly ? null : renderText(word.text, word.style, false, true);
					var outlineShadow:TextLine = bodyOnly ? null : renderText(word.text, word.style, false, false, true);
					
					// apply strikeout/underline hack
					if (style.strikeOut || style.underline == "underline")
						strikeOutUnderlineHack(word.ascent, word.style, body, outline, bodyShadow, outlineShadow);
					
					body.transform.matrix3D = new Matrix3D();
					if (!bodyOnly)
					{
						outline.transform.matrix3D = new Matrix3D();
						bodyShadow.transform.matrix3D = new Matrix3D();
						outlineShadow.transform.matrix3D = new Matrix3D();
					}
					
					// apply scaling
					body.scaleX = word.style.fontScaleX / 100;
					body.scaleY = word.style.fontScaleY / 100;
					if (!bodyOnly)
					{
						outline.scaleX = bodyShadow.scaleX = outlineShadow.scaleX = word.style.fontScaleX / 100;
						outline.scaleY = bodyShadow.scaleY = outlineShadow.scaleY = word.style.fontScaleY / 100;
					}
					
					// final alignment on render sprite applying pre-calulated positioning values (getLineRects())
					lastWordXWidth = firstWord ? caption.getLineRects()[l].x : lastWordXWidth;
					
					body.x = lastWordXWidth;
					body.y = caption.getLineRects()[l].y;
					if (!bodyOnly)
					{
						outline.x = lastWordXWidth;
						outline.y = caption.getLineRects()[l].y;
					}
					
					// set shadow position relative to word position
					if (!bodyOnly)
					{
						bodyShadow.x = outlineShadow.x = lastWordXWidth + word.style.shadowDepthX;
						bodyShadow.y = outlineShadow.y = caption.getLineRects()[l].y + word.style.shadowDepthY;
					}
					
					// apply transformations
					if (word.style.fontAngleX != 0 || word.style.fontAngleY != 0 || word.style.fontAngleZ != 0)
					{
						// now let's get some perspective
						body.transform.perspectiveProjection = getTransformPerspective(caption.transformPoint);
						if (!bodyOnly)
							outline.transform.perspectiveProjection = bodyShadow.transform.perspectiveProjection = outlineShadow.transform.perspectiveProjection = body.transform.perspectiveProjection;
						
						// Autobots TRANSFORM!
						body.transform.matrix3D = transform(body.transform.matrix3D.clone(), caption.transformPoint, word.style);
						if (!bodyOnly)
						{
							outline.transform.matrix3D = body.transform.matrix3D.clone();
							bodyShadow.transform.matrix3D = transform(bodyShadow.transform.matrix3D.clone(), caption.transformPoint, word.style);
							outlineShadow.transform.matrix3D = bodyShadow.transform.matrix3D.clone();
						}
					}
					
					// apply italic hack if needed
					if (word.style.fontEmbed && word.style.italic == "italic")
					{
						var doItalicHack:Boolean = false;
						var fontsFound:Array = FontLoader.getRegisteredFont(style.fontName, true, FontType.EMBEDDED_CFF);
						
						for (var f:int = 0; f < fontsFound.length; f++)
						{
							if (fontsFound[f].fontStyle != FontStyle.ITALIC || fontsFound[f].fontStyle != FontStyle.BOLD_ITALIC)
							{
								doItalicHack = true;
								break;
							}
						}
						
						// italic hack when no italic font is available for the embedded font
						if (doItalicHack)
						{
							body.transform.matrix3D = italicHack(body.transform.matrix3D.clone(), word.style);
							if (!bodyOnly)
							{
								outline.transform.matrix3D = body.transform.matrix3D.clone();
								bodyShadow.transform.matrix3D = italicHack(bodyShadow.transform.matrix3D.clone(), word.style);
								outlineShadow.transform.matrix3D = bodyShadow.transform.matrix3D.clone();
							}
						}
					}
					
					// apply filters
					body.filters = renderBody(word.style);
					if (!bodyOnly)
					{
						outline.filters = renderOutline(word.style);
						bodyShadow.filters = renderBodyShadow(word.style);
						outlineShadow.filters = renderOutlineShadow(word.style);
					}
					
					var renderedWord:Vector.<TextLine> = new Vector.<TextLine>;
					renderedWord.push(body, outline, bodyShadow, outlineShadow);
					
					lastWordXWidth += word.pixelWidth;
					firstWord = false;
					
					rendered.push(renderedWord);
				}
			}
			
			// shadow
			for (var so:int; so < rendered.length; so++)
				rendered[so][3] != null ? renderSprite.addChild(rendered[so][3]) : null;
			
			for (var sb:int; sb < rendered.length; sb++)
				rendered[sb][2] != null ? renderSprite.addChild(rendered[sb][2]) : null;
			
			// outline
			for (var o:int; o < rendered.length; o++)
				rendered[o][1] != null ? renderSprite.addChild(rendered[o][1]) : null;
			
			// body
			for (var b:int; b < rendered.length; b++)
				rendered[b][0] != null ? renderSprite.addChild(rendered[b][0]) : null;
			
			renderSprite.cacheAsBitmap = true;
			caption.renderSprite = renderSprite;
			
			/*var bitmapData:BitmapData = new BitmapData(container.getChildAt(0).width, container.getChildAt(0).height, true, 0x00FFFFFF);
			bitmapData.draw(caption.renderSprite, caption.renderSprite.transform.matrix);
			var bitmap:Bitmap = new Bitmap(bitmapData, "auto", true);
			bitmap.transform.matrix = caption.renderSprite.transform.matrix;
			caption.bitmap = bitmap;*/
			
			return caption;
		}
		
		public function add(caption_:ICaption, captionsOnDisplay_:Vector.<ICaption>, container:DisplayObjectContainer):void
		{
			var caption:ASSCaption = ASSCaption(caption_);
			var captionsOnDisplay:Vector.<ASSCaption> = Vector.<ASSCaption>(captionsOnDisplay_);
			
			if (!caption.effects.MOVE && !caption.effects.ORG && !caption.effects.BANNER && !caption.effects.SCROLL && !caption.isAnimated)
				handleCollisions(caption, caption.renderSprite, captionsOnDisplay, container);
			
			// let's keep "newer" captions at the front, while paying attention to layers
			var insertAt:int = -1;
			
			for (var c:int; c < captionsOnDisplay.length; c++)
			{
				if (captionsOnDisplay[c].event.layer > caption.event.layer)
				{
					try { insertAt = container.getChildIndex(captionsOnDisplay[c].renderSprite) - 1; } catch (error:Error) { }
				}
				else if (captionsOnDisplay[c].event.startSeconds > caption.event.startSeconds)
				{
					try { insertAt = container.getChildIndex(captionsOnDisplay[c].renderSprite) - 1; } catch (error:Error) { }
				}
			}
			
			try { insertAt == -1 ? container.addChild(caption.renderSprite) : container.addChildAt(caption.renderSprite, insertAt); } catch (error:Error) { }
			//try { insertAt == -1 ? container.addChild(caption.bitmap) : container.addChildAt(caption.bitmap, insertAt); } catch (error:Error) { }
		}
		
		public function remove(caption:ICaption, container:DisplayObjectContainer):void
		{
			try { container.removeChild(caption.renderSprite); } catch (error:Error) { }
			//try { container.removeChild(caption.bitmap); } catch (error:Error) { }
		}
		
		public function get parser():IParser
		{
			return _parser;
		}
	}
}