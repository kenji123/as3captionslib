package com.kenshisoft.captions.plugins.flowplayer
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import com.adobe.serialization.json.JSONDecoder;
	
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.view.Flowplayer;
	
	import com.kenshisoft.captions.Captions;
	import com.kenshisoft.captions.config.CaptionConfig;
	import com.kenshisoft.captions.config.Config;
	
	/**
	 * ...
	 * @author 
	 */
	public class FLPlugin extends Sprite implements Plugin
	{
		private var player:Flowplayer;
		private var model:PluginModel;
		
		private var config:Config;
		private var currentSubtitle:CaptionConfig;
		private var captionsContainer:Sprite = new Sprite();
		private var captions:Captions;
		
		public function FLPlugin()
		{
			super();
			
			captionsContainer.addChild(new TextField()); // quickfix. not sure why it needs this to work
			addChild(captionsContainer);
		}
		
		public function getDefaultConfig():Object
		{
			return {
				top: 0, 
				left: 0, 
				zIndex: 1
			};
		}
		
		public function onConfig(model:PluginModel):void
		{
			this.model = model;
			
			var args:Object;
			try
			{
				var jd:JSONDecoder = new JSONDecoder(model.config.args);
				args = jd.getValue();
			}
			catch (error:Error)
			{
				trace(error.getStackTrace());
			}
			
			config = new Config(args);
			
			currentSubtitle = config.getDefaultCaption();
			
			initCaptions();
		}
		
		private function initCaptions():void
		{
			captions = new Captions(config.captionsEnabled, config.captionsAnimated);
			captions.setContainer(captionsContainer);
			captions.fontsRegisteredSignal.add(onFontsRegistered);
		}
		
		public function onLoad(player:Flowplayer):void
		{
			this.player = player;
			
			this.player.playlist.onMetaData(onMetaData);
			this.player.playlist.onResized(onResized);
			this.player.playlist.onStart(onStart);
			this.player.playlist.onSeek(onSeek);
			
			model.dispatchOnLoad();
		}
		
		private function onMetaData(event:ClipEvent):void
		{
			captions.setStream(player.streamProvider.netStream);
		}
		
		public function onResized(event:ClipEvent):void
		{
			try
			{
				if (player.currentClip.getContent().parent)
				{
					var currentClip:DisplayObjectContainer = player.currentClip.getContent().parent;
					captions.setVideoRect(new Rectangle(currentClip.x, currentClip.y, currentClip.width, currentClip.height));
					captions.flush();
					captionsContainer.addChild(new TextField()); // quickfix. not sure why it needs this to work
				}
			}
			catch (error:Error)
			{
				trace(error.getStackTrace());
			}
        }
		
		private function onStart(event:ClipEvent):void
		{
			var currentClip:DisplayObjectContainer = player.currentClip.getContent().parent;
			captions.setVideoRect(new Rectangle(currentClip.x, currentClip.y, currentClip.width, currentClip.height));
			
			if (player.currentClip.duration == 0) return;
			
			loadFonts();
		}
		
		private function loadFonts():void
		{
			if (currentSubtitle.fonts.length > 0)
			{
				for (var k:int = 0, l:int = currentSubtitle.fonts.length; k < l; k++)
				{
					if (!currentSubtitle.fonts[k].registered)
					{
						captions.loadFontSwf(currentSubtitle.fonts[k]);
						return;
					}
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
			
			loadFonts();
		}
		
		private function loadCaptions():void
		{
			captions.loadCaptions(currentSubtitle.format, currentSubtitle.url);
		}
		
		private function onSeek(event:ClipEvent):void
		{
			captions.flush((player.streamProvider.netStream.time > 0 ? player.streamProvider.netStream.time : 0));
		}
	}
}