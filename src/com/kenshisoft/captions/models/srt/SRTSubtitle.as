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
		
		public function SRTSubtitle()
		{
			super();
		}
		
		public function get format():SubtitleFormat
        {
            return FORMAT;
		}
	}
}
