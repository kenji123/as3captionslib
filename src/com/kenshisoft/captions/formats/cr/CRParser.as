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
