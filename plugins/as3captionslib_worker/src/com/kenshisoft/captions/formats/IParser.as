package com.kenshisoft.captions.formats
{
	import com.kenshisoft.captions.FontClass;
	import com.kenshisoft.captions.models.ISubtitle;
	
	/**
	 * ...
	 * @author 
	 */
	public interface IParser
	{
		function parse(subtitleStr:String, fontClasses:Vector.<FontClass>):ISubtitle;
	}
}
