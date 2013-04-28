package com.kenshisoft.captions.formats.cr
{
	import com.kenshisoft.captions.FontClass;
	import com.kenshisoft.captions.formats.IParser;
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
			return new CRSubtitleScript();
		}
	}
}
