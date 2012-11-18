package com.kenshisoft.captions.plugins.jwplayer
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.player.IPlayer;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.plugins.PluginConfig;
	
	import com.adobe.serialization.json.JSON;
	
	import com.kenshisoft.captions.Captions;
	import com.kenshisoft.captions.FakeNetStream;
	import com.kenshisoft.captions.config.Config;
	import com.kenshisoft.captions.enums.SubtitleFormat;
	
	/**
	 * ...
	 * @author Jamal Edey
	 */
	public class JWPlugin extends Sprite implements IPlugin
	{
		private const ID:String = "as3captionslib";
		
		private var player:IPlayer;
		
		private var config:Config;
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
				args = JSON.decode(config.args);
			}
			catch (error:Error)
			{
				trace(error.getStackTrace());
			}
			
			this.config = new Config(args);
			
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
			resizeCaptionsToStage();
		}
		
		private function initCaptions():void
		{
			captions = new Captions(true, config.animateCaptions);
			captions.setContainer(captionsContainer);
			captions.setStream(fakeStream);
			captions.setVideoRect(new Rectangle(0, 0, player.controls.display.width, player.controls.display.height));
			
			loadFonts();
		}
		
		private function loadFonts():void
		{
			if (config.fonts.length < 1)
			{
				onFontsRegistered(null);
				return;
			}
			
			captions.fontsRegisteredSignal.add(onFontsRegistered);
			captions.loadFontSwf(config.fonts[0]);
		}
		
		private function onFontsRegistered(event:Object):void
		{
			for (var i:int; i < config.fonts.length; i++)
			{
				if (config.fonts[i].url == event.url)
					config.fonts[i].registered = true;
			}
			
			for (var j:int; j < config.fonts.length; j++)
			{
				if (!config.fonts[j].registered)
				{
					captions.loadFontSwf(config.fonts[j]);
					return;
				}
			}
			
			captions.loadCaptions(SubtitleFormat.ASS, config.getDefaultCaption().url);
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
		
		private function resizeCaptionsToStage():void
		{
			if (captions)
			{
				captions.setVideoRect(new Rectangle(0, 0, player.controls.display.width, player.controls.display.height));
				captions.flush();
			}
		}
	}
}