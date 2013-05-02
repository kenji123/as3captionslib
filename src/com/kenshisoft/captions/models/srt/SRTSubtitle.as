package com.kenshisoft.captions.models.srt
{
	import com.kenshisoft.captions.enums.SubtitleFormat;
	import com.kenshisoft.captions.models.ISubtitle;
	
	/**
	 * ...
	 * @author 
	 */
	public class SRTSubtitle implements ISubtitle
	{
		private static const FORMAT:SubtitleFormat = SubtitleFormat.SRT;
		
		private var _events:Vector.<SRTEvent> = new Vector.<SRTEvent>;
		
		public function SRTSubtitle()
		{
			super();
		}
		
		public function get events():Vector.<SRTEvent>
        {
            return _events;
		}
		
       	public function set events(value:Vector.<SRTEvent>):void
        {
            _events = value;
		}
		
		public function get format():SubtitleFormat
        {
            return FORMAT;
		}
	}
}
