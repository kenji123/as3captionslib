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
	import flash.text.FontType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	import flash.text.engine.FontMetrics;
	import flash.utils.getTimer;
	
	import com.kenshisoft.captions.FontClass;
	import com.kenshisoft.captions.SubtitleWord;
	import com.kenshisoft.captions.formats.IParser;
	import com.kenshisoft.captions.formats.ass.ASSCaption;
	import com.kenshisoft.captions.formats.ass.ASSEffect;
	import com.kenshisoft.captions.formats.ass.ASSRenderer;
	import com.kenshisoft.captions.enums.SubtitleEffect;
	import com.kenshisoft.captions.loaders.FontLoader;
	import com.kenshisoft.captions.misc.MarginRectangle;
	import com.kenshisoft.captions.misc.Size;
	import com.kenshisoft.captions.misc.Util;
	import com.kenshisoft.captions.models.ISubtitle;
	import com.kenshisoft.captions.models.ass.ASSEvent;
	import com.kenshisoft.captions.models.ass.ASSStyle;
	import com.kenshisoft.captions.models.ass.ASSSubtitle;
	
	public class ASSParser implements IParser
	{
		private var _fontClasses:Vector.<FontClass>;
		
		public function ASSParser()
		{
			super();
		}
		
		public function parse(subtitleStr:String, fontClasses:Vector.<FontClass>):ISubtitle
		{
			_fontClasses = fontClasses;
			
			// comment, picture, sound, movie, and command events are ignored
			var styleV5RegExp:RegExp = /(.*),(.*),(\d*),&H(.{0,8}?),&H(.{0,8}?),&H(.{0,8}?),&H(.{0,8}?),(-?\d),(-?\d),(-?\d),(-?\d),(\d*),(\d*),(\d*\.?\d*?),(\d*\.?\d*?),(\d*),(\d*\.?\d*?),(\d*\.?\d*?),(\d*),(\d*),(\d*),(\d*),(\d*)/im;
			var eventV5RegExp:RegExp = /(\d),(\d:\d\d:\d\d.\d\d),(\d:\d\d:\d\d.\d\d),(.*?),(.*?),(\d{4}),(\d{4}),(\d{4}),(.*?),(.*)/i;
			
			var subtitle:ASSSubtitle = new ASSSubtitle();
			var index:int;
			
			var lines:Vector.<String> = Vector.<String>(subtitleStr.replace(/$(\r\n|\n)/gim, "\r").split(/\r/));
			for (var i:int; i < lines.length; i++)
			{
				if (Util.trim(lines[i]).charAt(0) == ";") continue;
				
				var line:Vector.<String> = Vector.<String>([lines[i].substr(0, lines[i].indexOf(":")), lines[i].substr(lines[i].indexOf(":")+1)]);
				line[0] = Util.trim(line[0]);
				line[0] = line[0].toLocaleLowerCase();
				line[1] = Util.trim(line[1]);
				
				if (line[0] == "playresx")
				{
					subtitle.screenSize.width = int(line[1]);
					
					if (subtitle.screenSize.height <= 0)
						subtitle.screenSize.height = subtitle.screenSize.width == 1280 ? 1024 : subtitle.screenSize.width * 3 / 4;
				}
				
				if (line[0] == "playresy")
				{
					subtitle.screenSize.height = int(line[1]);
					
					if (subtitle.screenSize.width <= 0)
						subtitle.screenSize.width = subtitle.screenSize.height == 1024 ? 1280 : subtitle.screenSize.height * 4 / 3;
				}
				
				if (line[0] == "wrapstyle") subtitle.wrapStyle = int(line[1]);
				
				if (line[0] == "collisions") subtitle.collisions = line[1] == "reverse" ? 1 : 0;
				
				if (line[0] == "scaledborderandshadow") subtitle.scaledBorderAndShadow = line[1] == "yes" ? true : false;
				
				if (line[0] == "scripttype") subtitle.scriptVersion = subtitle.styleVersion = line[1].indexOf("4.00++") >= 0 ? 6 : (line[1].indexOf("4.00+") >= 0 ? 5 : (line[1].indexOf("4.00") >= 0 ? 4 : 3));
				
				if (line[0] == "[v4 styles]") subtitle.styleVersion = 4;
				
				if (line[0] == "[v4+ styles]") subtitle.styleVersion = 5;
				
				if (line[0] == "[v4++ styles]") subtitle.styleVersion = 6;
				
				
				if (line[0] == "title") subtitle.title = line[1];
				
				if (line[0] == "original script") subtitle.originalScript = line[1];
				
				if (line[0] == "original translation") subtitle.originalTranslation = line[1];
				
				if (line[0] == "original editing") subtitle.originalEditing = line[1];
				
				if (line[0] == "original timing") subtitle.originalTiming = line[1];
				
				if (line[0] == "synch point") subtitle.synchPoint = line[1];
				
				if (line[0] == "script updated by") subtitle.scriptUpdatedBy = line[1];
				
				if (line[0] == "update details") subtitle.updateDetails = line[1];
				
				if (line[0] == "playdepth") subtitle.playDepth = line[1];
				
				if (line[0] == "timer") subtitle.timer = Number(line[1]);
				
				
				if (line[0] == "style")
				{
					var styleMatch:Object;
					//if (subtitle.styleVersion == 3) styleMatch = styleV3RegExp.exec(line[1]);
					//if (subtitle.styleVersion == 4) styleMatch = styleV4RegExp.exec(line[1]);
					if (subtitle.styleVersion == 5) styleMatch = styleV5RegExp.exec(line[1]);
					//if (subtitle.styleVersion == 6) styleMatch = styleV6RegExp.exec(line[1]);
					
					if(styleMatch != null)
					{
						index = 1;
						
						var style:ASSStyle = new ASSStyle();
						style.name = styleMatch[index++];
						style.fontName = getFontNameByAlias(String(styleMatch[index++]).replace(/^@/, ''), fontClasses);
						style.fontSize = style.orgFontSize = Number(styleMatch[index++]);
						style.colours = new Vector.<uint>; style.colours.push("0x" + styleMatch[index++], "0x" + styleMatch[index++], "0x" + styleMatch[index++], "0x" + styleMatch[index++]);
						style.fontWeight = int(styleMatch[index++]) < 0 ? "bold" : "normal";
						style.italic = int(styleMatch[index++]) < 0 ? "italic" : "normal";
						if (subtitle.styleVersion >= 5) style.underline = int(styleMatch[index++]) < 0 ? "underline" : "none";
						if (subtitle.styleVersion >= 5) style.strikeOut = int(styleMatch[index++]) < 0 ? true : false;
						if (subtitle.styleVersion >= 5) style.fontScaleX = Number(styleMatch[index]) > 0 ? Number(styleMatch[index]) : 0; index++;
						if (subtitle.styleVersion >= 5) style.fontScaleY = Number(styleMatch[index]) > 0 ? Number(styleMatch[index]) : 0; index++;
						if (subtitle.styleVersion >= 5) style.fontSpacing = Number(styleMatch[index]) > 0 ? Number(styleMatch[index]) : 0; index++;
						if (subtitle.styleVersion >= 5) style.fontAngleZ = Number(styleMatch[index++]);
						if (subtitle.styleVersion >= 4) { style.borderStyle = int(styleMatch[index++]); } style.borderStyle = style.borderStyle == 1 ? 0 : style.borderStyle == 3 ? 1 : 0;
						style.outlineWidthX = style.outlineWidthY = Number(styleMatch[index]) > 0 ? Number(styleMatch[index]) : 0; index++;
						style.shadowDepthX = style.shadowDepthY = Number(styleMatch[index]) > 0 ? Number(styleMatch[index]) : 0; index++;
						style.alignment = int(styleMatch[index++]); if (subtitle.styleVersion <= 4) style.alignment = (style.alignment&4) ? ((style.alignment&3)+6) /* top */ : (style.alignment&8) ? ((style.alignment&3)+3) /* mid */ : (style.alignment&3); /* bottom */
						style.marginRect = new MarginRectangle(int(styleMatch[index++]), int(styleMatch[index++]), int(styleMatch[index]), int(styleMatch[index++]));
						if (subtitle.styleVersion >= 6) style.marginRect.bottom = int(styleMatch[index++]);
						if (subtitle.styleVersion <= 4)
						{
							style.colours[2] = style.colours[3];
							
							var alpha:int = int(styleMatch[index]) < 0xff ? int(styleMatch[index]) : 0xff; index++; alpha = alpha > 0 ? alpha : 0;
							for (var j:int; j < 3; j++)
								style.colours[j] = alpha << 24 | Util.removeAlpha(style.colours[j]);
							
							style.colours[3] = 0x80 << 24 | Util.removeAlpha(style.colours[3]);
						}
						style.charSet = int(styleMatch[index++]);
						if (subtitle.styleVersion >= 6) style.relativeTo = int(styleMatch[index++]);
						
						setTrueFontHeight(style);
						
						subtitle.styles.push(style);
					}
				}
				
				if (line[0] == "dialogue")
				{
					var eventMatch:Object;
					//if (subtitle.scriptVersion == 3) eventMatch = eventV3RegExp.exec(line[1]);
					//if (subtitle.scriptVersion == 4) eventMatch = eventV4RegExp.exec(line[1]);
					if (subtitle.scriptVersion == 5) eventMatch = eventV5RegExp.exec(line[1]);
					//if (subtitle.scriptVersion == 6) eventMatch = eventV6RegExp.exec(line[1]);
					
					if(eventMatch != null)
					{
						index = 1;
						
						var event:ASSEvent = new ASSEvent();
						if (subtitle.scriptVersion <= 4) { eventMatch[index++]; } /* Marked = */
						if (subtitle.scriptVersion >= 5) event.layer = int(eventMatch[index++]);
						event.start = eventMatch[index++];
						event.end = eventMatch[index++];
						event.style = eventMatch[index++]; event.style = event.style.length > 0 ? event.style : "Default";
						event.actor = eventMatch[index++];
						event.marginRect = new MarginRectangle(int(eventMatch[index++]), int(eventMatch[index++]), int(eventMatch[index]), int(eventMatch[index++]));
						if (subtitle.scriptVersion >= 6) event.marginRect.bottom = int(eventMatch[index++]);
						event.effect = eventMatch[index++];
						event.text = eventMatch[10];
						
						event.id = subtitle.events.length;
						event.startSeconds = Util.toSeconds(event.start);
						event.endSeconds = Util.toSeconds(event.end);
						event.duration = event.endSeconds - event.startSeconds;
						
						subtitle.events.push(event);
					}
				}
			}
			
			// change non-existent styles to use the default style
			for (var m:int; m < subtitle.events.length; m++)
			{
				if (getStyle(subtitle.events[m].style, subtitle.styles).name != subtitle.events[m].style)
					subtitle.events[m].style = "Default";
			}
			
			// set screen size, if not set in script
			if (subtitle.screenSize == new Size(0, 0))
				subtitle.screenSize = new Size(384, 288);
			
			// sort events in ascending order by startSeconds
			var temp:ASSEvent; // holding variable
			var numLength:int = subtitle.events.length;
			for (var k:int; k < (numLength - 1); k++) // element to be compared
			{
				for(var l:int = (k + 1); l < numLength; l++) // rest of the elements
				{
					if (subtitle.events[k].startSeconds > subtitle.events[l].startSeconds) // ascending order
					{
						temp = subtitle.events[k].copy(); // swap
						subtitle.events[k] = subtitle.events[l].copy();
						subtitle.events[l] = temp;
					}
				}
			}
			
			return subtitle;
		}
		
		public function parseEffect(caption:ASSCaption, str:String):void
		{
			str = Util.trim(str);
			if (!caption || str.length == 0) return;
			
			var effect:String = str.substr(0, str.indexOf(";") + 1);
			var params:String = str.substr(str.indexOf(";") + 1);
			
			var bannerRegExp:RegExp = /(\d+);(\d+);(\d+)/;
			var scrollRegExp:RegExp = /(\d+);(\d+);(\d+);(\d+)/;
			var paramMatch:Object;
			
			var e:ASSEffect;
			
			if (effect.toLowerCase() == "banner;") // Banner;delay=param[0][;leftoright=param[1];fadeawaywidth=param[2]]
			{
				paramMatch = bannerRegExp.exec(params);
				if (paramMatch == null) return;
				
				e = new ASSEffect(SubtitleEffect.BANNER);
				
				e.param[0] = int(1.0 * paramMatch[1] / caption.scaleX); e.param[0] = e.param[0] > 1 ? e.param[0] : 1;
				e.param[1] = paramMatch[2];
				e.param[2] = int(caption.scaleX * paramMatch[3]);
				
				caption.effects.BANNER = e;
				caption.effects.COUNT += 1;
				caption.wrapStyle = 2;
			}
			else if (effect.toLowerCase() == "scroll up;" || effect.toLowerCase() == "scroll down;") // Scroll up/down(toptobottom=param[3]);top=param[0];bottom=param[1];delay=param[2][;fadeawayheight=param[4]]
			{
				paramMatch = scrollRegExp.exec(params);
				if (paramMatch == null) return;
				
				var tmp:int;
				if (paramMatch[1] > paramMatch[2]) { tmp = paramMatch[1]; paramMatch[1] = paramMatch[2]; paramMatch[2] = tmp; }
				
				e = new ASSEffect(SubtitleEffect.SCROLL);
				
				e.param[0] = int(caption.scaleY * paramMatch[1] * 8);
				e.param[1] = int(caption.scaleY * paramMatch[2] * 8);
				e.param[2] = int(1.0 * paramMatch[3] / caption.scaleY); e.param[2] = e.param[2] > 1 ? e.param[2] : 1;
				e.param[3] = (effect.length == 12);
				e.param[4] = int(caption.scaleY * paramMatch[4]);
				
				caption.effects.SCROLL = e;
				caption.effects.COUNT += 1;
			}
		}
		
		public function parseTag(str:String):Vector.<Vector.<String>>
		{
			var tags:Vector.<String> = Vector.<String>(str.split("\\"));
			var tagsParsed:Vector.<Vector.<String>> = new Vector.<Vector.<String>>;
			
			for (var i:int; i < tags.length; i++)
			{
				var tag:String = tags[i];
				var tagParams:Vector.<String> = new Vector.<String>;
				
				if (tag.indexOf("1c") == 0 || tag.indexOf("2c") == 0 || tag.indexOf("3c") == 0 || tag.indexOf("4c") == 0)
				{
					tagParams.push(tag.substr(0, 2), "0x" + tag.substr(4, (tag.length - 1) - 4));
				}
				else if (tag.indexOf("1a") == 0 || tag.indexOf("2a") == 0 || tag.indexOf("3a") == 0 || tag.indexOf("4a") == 0)
				{
					tagParams.push(tag.substr(0, 2), "0x" + tag.substr(4, (tag.length - 1) - 4));
				}
				else if (tag.indexOf("alpha") == 0)
				{
					tagParams.push("alpha", "0x" + tag.substr(7, (tag.length - 1) - 7));
				}
				else if (tag.indexOf("an") == 0)
				{
					tagParams.push("an", tag.substr(2));
				}
				else if (tag.indexOf("a") == 0)
				{
					tagParams.push("a", tag.substr(1));
				}
				else if (tag.indexOf("blur") == 0)
				{
					tagParams.push("blur", tag.substr(4));
				}
				else if (tag.indexOf("bord") == 0)
				{
					tagParams.push("bord", tag.substr(4));
				}
				else if (tag.indexOf("be") == 0)
				{
					tagParams.push("be", tag.substr(2));
				}
				else if (tag.indexOf("b") == 0)
				{
					tagParams.push("b", tag.substr(1));
				}
				else if (tag.indexOf("clip") == 0)
				{
					//TODO:
				}
				else if (tag.indexOf("c") == 0)
				{
					tagParams.push("c", "0x" + tag.substr(3, (tag.length - 1) - 3));
				}
				else if (tag.indexOf("fade") == 0 || tag.indexOf("fad") == 0)
				{
					tagParams = Vector.<String>(tag.substr(tag.indexOf("(")+1, (tag.length-1)-(tag.indexOf("(")+1)).split(","));
					tagParams.unshift("fade");
				}
				else if (tag.indexOf("fe") == 0)
				{
					tagParams.push("fe", tag.substr(2));
				}
				else if (tag.indexOf("fn") == 0)
				{
					tagParams.push("fn", tag.substr(2));
				}
				else if (tag.indexOf("frx") == 0 || tag.indexOf("fry") == 0 || tag.indexOf("frz") == 0)
				{
					tagParams.push(tag.substr(0, 3), tag.substr(3));
				}
				else if (tag.indexOf("fr") == 0)
				{
					tagParams.push("fr", tag.substr(2));
				}
				else if (tag.indexOf("fax") == 0 || tag.indexOf("fay") == 0)
				{
					tagParams.push(tag.substr(0, 3), tag.substr(3));
				}
				else if (tag.indexOf("fscx") == 0 || tag.indexOf("fscy") == 0)
				{
					tagParams.push(tag.substr(0, 4), tag.substr(4));
				}
				else if (tag.indexOf("fsc") == 0)
				{
					tagParams.push("fsc", tag.substr(3));
				}
				else if (tag.indexOf("fsp") == 0)
				{
					tagParams.push("fsp", tag.substr(3));
				}
				else if (tag.indexOf("fs") == 0)
				{
					tagParams.push("fs", tag.substr(2));
				}
				else if (tag.indexOf("iclip") == 0)
				{
					//TODO:
				}
				else if (tag.indexOf("i") == 0)
				{
					tagParams.push("i", tag.substr(1));
				}
				else if (tag.indexOf("kt") == 0 || tag.indexOf("kf") == 0 || tag.indexOf("ko") == 0)
				{
					tagParams.push(tag.substr(0, 2), tag.substr(2));
				}
				else if (tag.indexOf("k") == 0 || tag.indexOf("K") == 0)
				{
					tagParams.push(tag.substr(0, 1), tag.substr(1));
				}
				else if (tag.indexOf("move") == 0)
				{
					tagParams = Vector.<String>(tag.substr(tag.indexOf("(")+1, (tag.length-1)-(tag.indexOf("(")+1)).split(","));
					tagParams.unshift("move");
				}
				else if (tag.indexOf("org") == 0)
				{
					tagParams = Vector.<String>(tag.substr(tag.indexOf("(")+1, (tag.length-1)-(tag.indexOf("(")+1)).split(","));
					tagParams.unshift("org");
				}
				else if (tag.indexOf("pbo") == 0)
				{
					tagParams.push("pbo", tag.substr(3));
				}
				else if (tag.indexOf("pos") == 0)
				{
					tagParams = Vector.<String>(tag.substr(tag.indexOf("(")+1, (tag.length-1)-(tag.indexOf("(")+1)).split(","));
					tagParams.unshift("pos");
				}
				else if (tag.indexOf("p") == 0)
				{
					tagParams.push("p", tag.substr(1));
				}
				else if (tag.indexOf("q") == 0)
				{
					tagParams.push("q", tag.substr(1));
				}
				else if (tag.indexOf("r") == 0)
				{
					tagParams.push("r", tag.substr(1));
				}
				else if (tag.indexOf("shad") == 0)
				{
					tagParams.push("shad", tag.substr(4));
				}
				else if (tag.indexOf("s") == 0)
				{
					tagParams.push("s", tag.substr(1));
				}
				else if (tag.indexOf("t") == 0)
				{
					tagParams.push("t");
					var start_end_accel:Vector.<String> = Vector.<String>((tag.substr(2, (tag.length-1)-2)).split(","));
					if (start_end_accel.length == 2) tagParams.push(start_end_accel[0], start_end_accel[1]);
					if (start_end_accel.length == 4) tagParams.push(start_end_accel[3]);
					
					tag = tags[++i];
					var tTags:String = "";
					while (tag.charAt(tag.length-1) != ")")
					{
						tTags += "\\" + tag.substr(0,tag.length-1);
						if (i + 1 >= tags.length)
							break;
						else
							tag = tags[++i];
					}
					tagParams.push(tTags + "\\" + tag.substr(0, tag.length-1));
				}
				else if (tag.indexOf("u") == 0)
				{
					tagParams.push("u", tag.substr(1));
				}
				else if (tag.indexOf("xbord") == 0)
				{
					tagParams.push("xbord", tag.substr(5));
				}
				else if (tag.indexOf("xshad") == 0)
				{
					tagParams.push("xshad", tag.substr(5));
				}
				else if (tag.indexOf("ybord") == 0)
				{
					tagParams.push("ybord", tag.substr(5));
				}
				else if (tag.indexOf("yshad") == 0)
				{
					tagParams.push("yshad", tag.substr(5));
				}
				
				if (tagParams.length > 0) tagsParsed.push(tagParams);
			}
			
			return tagsParsed;
		}
		
		public function parseString(caption:ASSCaption, str:String, style:ASSStyle, renderer:ASSRenderer, styleStr:String):void
		{
			//var start_time:int = getTimer();
			//var start:Number = new Date().time;
			str = str.replace(/\\N/g, '\n');
			str = str.replace(/\\n/g, (caption.wrapStyle < 2 || caption.wrapStyle == 3) ? ' ' : '\n');
			str = str.replace(/\\h/g, ' ');// '\x00A0');
			
			for (var i:int, j:int; j <= str.length; j++)
			{
				var c:String = str.charAt(j);
				
				if (c != '\n' && c != ' ' && c.length != 0)
					continue;
				
				if (i < j)
					caption.words.push(new SubtitleWord(str.substr(i, j - i), style, renderer, styleStr));
				
				if (c == '\n')
					caption.words.push(new SubtitleWord('\n', style, renderer, styleStr));
				else if (c == ' ')
					caption.words.push(new SubtitleWord(' ', style, renderer, styleStr));
				
				i = j + 1;
			}
			
			/*str = str.replace(/\\N/g, '\n').replace(/\\n/g, (caption.wrapStyle < 2 || caption.wrapStyle == 3) ? ' ' : '\n').replace(/\\h/g, ' ');// '\x00A0');
			
			var lines:Array = str.split('\n');
			var textRegExp:RegExp = /([^\s]+)|(\s)/g;
			
			for (var i:int; i < lines.length; i++)
			{
				var match:Object = textRegExp.exec(lines[i]);
				
				while (match != null)
				{
					caption.words.push(new SubtitleWord((match[1] ? match[1] : match[2]), style, renderer, styleStr));
					
					match = textRegExp.exec(lines[i]);
				}
				
				if (i != lines.length - 1)
					caption.words.push(new SubtitleWord('\n', style, renderer, styleStr));
			}*/
			//trace("execution time: ", getTimer()-start_time);
			//trace(new Date().time-start);
		}
		
		public function parsePolygon(caption:ASSCaption, str:String, style:ASSStyle):void
		{
			//TODO: \p drawing commands
		}
		
		public function stripTags(str:String):String
		{
			return str.replace(/({.*?})/gi, "");
		}
		
		public function getStyle(name:String, styles:Vector.<ASSStyle>):ASSStyle
		{
			for (var i:int; i < styles.length; i++)
			{
				if(styles[i].name == name)
					return styles[i];
			}
			
			return new ASSStyle();
		}
		
		// hack to allow fonts to be referred by name or family
		public function getFontNameByAlias(fontName:String, fontClasses:Vector.<FontClass>):String
		{
			var fontEmbed:Boolean = FontLoader.isFontRegistered(fontName, false, true) ? true : false;
			if (!fontEmbed)
			{
				// try aliases
				for (var i:int; i < fontClasses.length; i++)
				{
					for (var j:int = 0; j < fontClasses[i].aliases.length; j++)
					{
						if (fontName == fontClasses[i].aliases[j])
							return fontClasses[i].fontFamily;
					}
				}
			}
			
			return fontName;
		}
		
		//TODO: find a better way to get true font height
		public function setTrueFontHeight(style:ASSStyle):void
		{
			var dev:Boolean = FontLoader.isFontRegistered(style.fontName, false, true, null, FontType.DEVICE);
			var df3:Boolean = FontLoader.isFontRegistered(style.fontName, true, true, null, FontType.EMBEDDED);
			var df4:Boolean = FontLoader.isFontRegistered(style.fontName, true, true, null, FontType.EMBEDDED_CFF);
			style.fontEmbed = df3 || df4;
			
			var trueSize:Number = style.orgFontSize / 2;
			
			if (dev || df3 || !df4)
			{
				do
				{
					trueSize += 1;
					var tf:TextField = new TextField();
					tf.embedFonts = dev ? false : style.fontEmbed;
					tf.defaultTextFormat = new TextFormat(style.fontName, trueSize, null, style.fontWeight, style.italic);
					tf.text = 'the cow jumped\nover the moon';
					var tlm:TextLineMetrics = tf.getLineMetrics(1);
				}
				while (tlm.height <= style.orgFontSize && tlm.height != 0);
				
				if (tlm.height != 0)
				{
					style.fontSize = trueSize;
					return;
				}
			}
			
			if (df4)
			{
				do
				{
					trueSize += 1;
					var elementFormat:ElementFormat = new ElementFormat();
					elementFormat.fontDescription = new FontDescription(style.fontName, style.fontWeight, style.italic, (style.fontEmbed ? FontLookup.EMBEDDED_CFF : FontLookup.DEVICE));
					elementFormat.fontSize = trueSize;
					var fontMetrics:FontMetrics = elementFormat.getFontMetrics();
					//var leading:Number = trueSize * 0.2;
					//var height:Number = (int((leading + fontMetrics.emBox.height) * 100)) / 100;
					var leading:Number = fontMetrics.emBox.height * 0.2;
					var height:Number = fontMetrics.emBox.height + leading;
				}
				while (height <= style.orgFontSize && height != 0);
				
				if (height != 0)
				{
					style.fontSize = trueSize;
					return;
				}
			}
		}
		
		public function get fontClasses():Vector.<FontClass>
		{
			return _fontClasses;
		}
	}
}
