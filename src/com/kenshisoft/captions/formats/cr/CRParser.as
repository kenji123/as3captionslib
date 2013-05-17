package com.kenshisoft.captions.formats.cr
{
	import com.kenshisoft.captions.FontClass;
	import com.kenshisoft.captions.formats.IParser;
	import com.kenshisoft.captions.misc.MarginRectangle;
	import com.kenshisoft.captions.misc.Util;
	import com.kenshisoft.captions.models.cr.CREvent;
	import com.kenshisoft.captions.models.cr.CRStyle;
	import com.kenshisoft.captions.models.ISubtitle;
	import com.kenshisoft.captions.models.cr.CRSubtitleScript;
	import com.kenshisoft.captions.SubtitleWord;
	
	/**
	 * ...
	 * @author 
	 */
	public class CRParser implements IParser
	{
		
		public function CRParser()
		{
			super();
		}
		
		public function parse(subtitleStr:String, fontClasses:Vector.<FontClass>):ISubtitle
		{
			var subtitleXml:XML = new XML(subtitleStr);
			var subtitle:CRSubtitleScript = new CRSubtitleScript();
			
			subtitle.id = subtitleXml.@id;
			subtitle.title = subtitleXml.@title;
			subtitle.play_res_x = subtitleXml.@play_res_x;
			subtitle.play_res_y = subtitleXml.@play_res_y;
			subtitle.wrap_style = subtitleXml.@wrap_style;
			
			subtitle.lang_code = subtitleXml.@lang_code;
			subtitle.lang_string = subtitleXml.@lang_string;
			subtitle.created = subtitleXml.@created;
			subtitle.progress_string = subtitleXml.@progresss_string;
			subtitle.status_string = subtitleXml.@status_string;
			
			var i:String;
			
			var styles:XMLList = subtitleXml.styles.style;
			for (i in styles)
			{
				var style:CRStyle = new CRStyle();
				style.id = styles[i].@id;
				style.name = styles[i].@name;
				style.font_name = styles[i].@font_name;
				style.font_size = styles[i].@font_size;
				style.colours = new Vector.<uint>; style.colours.push(uint("0x" + String(styles[i].@primary_colour).substr(2)), uint("0x" + String(styles[i].@secondary_colour).substr(2)), uint("0x" + String(styles[i].@outline_colour).substr(2)), uint("0x" + String(styles[i].@back_colour).substr(2)));
				style.bold = styles[i].@bold;
				style.italic = styles[i].@italic;
				style.underline = styles[i].@underline;
				style.border_style = styles[i].@border_style;
				style.outline = styles[i].@outline;
				style.shadow = styles[i].@shadow;
				style.alignment = styles[i].@alignment;
				style.margin = new MarginRectangle(styles[i].@margin_l, styles[i].@margin_r, styles[i].@margin_v, styles[i].@margin_v);
				
				style.angle = styles[i].@angle;
				
				subtitle.styles.push(style);
			}
			
			var events:XMLList = subtitleXml.events.event;
			for (i in events)
			{
				var event:CREvent = new CREvent();
				event.id = events[i].@id;
				event.start = events[i].@start;
				event.end = events[i].@end;
				event.margin = new MarginRectangle(events[i].@margin_l, events[i].@margin_r, events[i].@margin_v, events[i].@margin_v);
				event.text = events[i].@text;
				
				event.style = events[i].@style;
				event.name = events[i].@name;
				event.effect = events[i].@effect;
				
				event.startSeconds = Util.toSeconds(event.start);
				event.endSeconds = Util.toSeconds(event.end);
				event.duration = event.endSeconds - event.startSeconds;
				
				subtitle.events.push(event);
			}
			
			return subtitle;
		}
		
		public function parseTag(str:String):Vector.<Vector.<String>>
		{
			var tags:Vector.<String> = Vector.<String>(str.split("\\"));
			var tagsParsed:Vector.<Vector.<String>> = new Vector.<Vector.<String>>;
			
			for (var i:int; i < tags.length; i++)
			{
				var tag:String = tags[i];
				var tagParams:Vector.<String> = new Vector.<String>;
				
				if (tag.indexOf("an") == 0)
				{
					tagParams.push("an", tag.substr(2));
				}
				else if (tag.indexOf("a") == 0)
				{
					tagParams.push("a", tag.substr(2));
				}
				else if (tag.indexOf("b") == 0)
				{
					tagParams.push("b", tag.substr(1));
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
				else if (tag.indexOf("fn") == 0)
				{
					tagParams.push("fn", tag.substr(2));
				}
				else if (tag.indexOf("fs") == 0)
				{
					tagParams.push("fs", tag.substr(2));
				}
				else if (tag.indexOf("i") == 0)
				{
					tagParams.push("i", tag.substr(1));
				}
				else if (tag.indexOf("q") == 0)
				{
					tagParams.push("q", tag.substr(1));
				}
				else if (tag.indexOf("u") == 0)
				{
					tagParams.push("u", tag.substr(1));
				}
				
				if (tagParams.length > 0) tagsParsed.push(tagParams);
			}
			
			return tagsParsed;
		}
		
		/*public function parseString(caption:CRCaption, str:String, style:CRStyle, renderer:CRRenderer, styleStr:String):void
		{
			str = str.replace(/\\N/g, '\n').replace(/\\n/g, (caption.wrapStyle < 2 || caption.wrapStyle == 3) ? ' ' : '\n')
			
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
			}
		}*/
		
		public function getStyle(name:String, styles:Vector.<CRStyle>):CRStyle
		{
			for (var i:int; i < styles.length; i++)
			{
				if(styles[i].name == name)
					return styles[i];
			}
			
			return new CRStyle();
		}
	}
}
