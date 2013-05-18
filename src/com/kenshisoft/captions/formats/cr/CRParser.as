package com.kenshisoft.captions.formats.cr
{
	import flash.text.FontType;
	
	import com.kenshisoft.captions.FontClass;
	import com.kenshisoft.captions.formats.IParser;
	import com.kenshisoft.captions.loaders.FontLoader;
	import com.kenshisoft.captions.misc.MarginRectangle;
	import com.kenshisoft.captions.misc.Util;
	import com.kenshisoft.captions.models.ISubtitle;
	import com.kenshisoft.captions.models.cr.CREvent;
	import com.kenshisoft.captions.models.cr.CRStyle;
	import com.kenshisoft.captions.models.cr.CRSubtitleScript;
	
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
			subtitle.lang_code = subtitleXml.@lang_code;
			subtitle.lang_string = subtitleXml.@lang_string;
			subtitle.created = subtitleXml.@created;
			subtitle.progress_string = subtitleXml.@progresss_string;
			subtitle.status_string = subtitleXml.@status_string;
			subtitle.wrap_style = subtitleXml.@wrap_style;
			
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
				style.bold = styles[i].@bold > 0 ? true : false;
				style.italic = styles[i].@italic > 0 ? true : false;
				style.underline = styles[i].@underline > 0 ? true : false;
				style.strikeout = styles[i].@srikeout > 0 ? true : false;
				style.scale_x = styles[i].@scale_x;
				style.scale_y = styles[i].@scale_y;
				style.spacing = styles[i].@spacing;
				style.angle = styles[i].@angle;
				style.border_style = styles[i].@border_style;
				style.outline = styles[i].@outline;
				style.shadow = styles[i].@shadow;
				style.alignment = styles[i].@alignment;
				style.margin = new MarginRectangle(styles[i].@margin_l, styles[i].@margin_r, styles[i].@margin_v, styles[i].@margin_v);
				style.encoding = styles[i].@encoding;
				
				subtitle.styles.push(style);
			}
			
			var events:XMLList = subtitleXml.events.event;
			for (i in events)
			{
				var event:CREvent = new CREvent();
				event.id = events[i].@id;
				event.start = events[i].@start;
				event.end = events[i].@end;
				event.style = events[i].@style;
				event.name = events[i].@name;
				event.margin = new MarginRectangle(events[i].@margin_l, events[i].@margin_r, events[i].@margin_v, events[i].@margin_v);
				event.effect = events[i].@effect;
				event.text = events[i].@text;
				
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
					tagParams.push("a", tag.substr(1));
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
		
		public function getStyle(name:String, styles:Vector.<CRStyle>):CRStyle
		{
			for (var i:int; i < styles.length; i++)
			{
				if(styles[i].name == name)
					return styles[i];
			}
			
			return new CRStyle();
		}
		
		public function isFontEmbedded(fontName:String):Boolean
		{
			var df3:Boolean = FontLoader.isFontRegistered(fontName, true, true, null, FontType.EMBEDDED);
			var df4:Boolean = FontLoader.isFontRegistered(fontName, true, true, null, FontType.EMBEDDED_CFF);
			
			return df3 || df4;
		}
	}
}
