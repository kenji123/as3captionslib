package com.kenshisoft.captions.plugins.jwplayer
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.player.IPlayer;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.plugins.PluginConfig;
	
	import com.kenshisoft.captions.Captions;
	import com.kenshisoft.captions.FakeNetStream;
	import com.kenshisoft.captions.config.CaptionConfig;
	import com.kenshisoft.captions.config.Config;
	
	/**
	 * ...
	 * @author Jamal Edey
	 */
	public class JWPlugin extends Sprite implements IPlugin
	{
		private const ID:String = "as3captionslib";
		
		private var player:IPlayer;
		
		private var config:Config;
		private var currentSubtitle:CaptionConfig;
		private var captionsContainer:Sprite = new Sprite();
		private var fakeStream:FakeNetStream = new FakeNetStream();
		private var captions:Captions;
		
		public function JWPlugin()
		{
			super();
			
			addChild(captionsContainer);
		}
		
		public function initPlugin(player:IPlayer, config:PluginConfig):void
		{
			this.player = player;
			
			var args:Object;
			try
			{
				args = JSON.parse(config.args);
			}
			catch (error:Error)
			{
				trace(error.getStackTrace());
			}
			
			this.config = new Config(args);
			
			currentSubtitle = config.getDefaultCaption();
			
			initCaptions();
			
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, onMediaTime);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_SEEK, onMediaSeek);
		}
		
		public function get id():String
		{
			return ID;
		}
		
		public function resize(width:Number, height:Number):void
		{
			if (captions)
			{
				captions.setVideoRect(new Rectangle(0, 0, player.controls.display.width, player.controls.display.height));
				captions.flush();
			}
		}
		
		private function onMediaTime(event:MediaEvent):void
		{
			fakeStream.time = event.position;
		}
		
		private function onMediaSeek(event:MediaEvent):void
		{
			if (captions)
				captions.flush((event.offset > 0 ? event.offset : 0));
		}
		
		private function initCaptions():void
		{
			captions = new Captions(true, config.captionsAnimated);
			captions.setContainer(captionsContainer);
			captions.setStream(fakeStream);
			captions.setVideoRect(new Rectangle(0, 0, player.controls.display.width, player.controls.display.height));
			
			loadFonts();
		}
		
		private function loadFonts():void
		{
			if (currentSubtitle.fonts.length < 1)
			{
				loadCaptions();
				return;
			}
			
			for (var k:int = 0, l:int = currentSubtitle.fonts.length; k < l; k++)
			{
				if (!currentSubtitle.fonts[k].registered)
				{
					captions.loadFontSwf(currentSubtitle.fonts[k]);
					return;
				}
			}
			
			loadCaptions();
		}
		
		private function onFontsRegistered(event:Object):void
		{
			for (var i:int = 0, j:int = currentSubtitle.fonts.length; i < j; i++)
			{
				if (currentSubtitle.fonts[i].url == event.url)
					currentSubtitle.fonts[i].registered = true;
			}
			
			for (var k:int = 0, l:int = currentSubtitle.fonts.length; k < l; k++)
			{
				if (!currentSubtitle.fonts[k].registered)
				{
					captions.loadFontSwf(currentSubtitle.fonts[k]);
					return;
				}
			}
			
			loadCaptions();
		}
		
		private function loadCaptions():void
		{
			captions.loadCaptions(currentSubtitle.format, currentSubtitle.url);
		}
	}
}