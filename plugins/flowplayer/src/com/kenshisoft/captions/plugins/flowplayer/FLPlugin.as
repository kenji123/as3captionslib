package com.kenshisoft.captions.plugins.flowplayer
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import org.flowplayer.model.PlayerEvent;
	
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.view.Flowplayer;
	
	import com.adobe.serialization.json.JSON;
	
	import com.kenshisoft.captions.Captions;
	import com.kenshisoft.captions.config.Config;
	import com.kenshisoft.captions.enums.SubtitleFormat;
	
	/**
	 * ...
	 * @author 
	 */
	public class FLPlugin extends Sprite implements Plugin
	{
		private var player:Flowplayer;
		private var model:PluginModel;
		
		private var config:Config;
		private var captionsContainer:Sprite = new Sprite();
		private var captions:Captions;
		
		private var sh:Shape;
		private var sp:Sprite;
		private var tf:TextField;
		
		public function FLPlugin()
		{
			super();
			
			captionsContainer.addChild(new TextField()); // why doesn't flowplayer like empty display objects?
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
				args = JSON.decode(model.config.args);
			}
			catch (error:Error)
			{
				trace(error.getStackTrace());
			}
			
			this.config = new Config(args);
		}
		
		public function onLoad(player:Flowplayer):void
		{
			this.player = player;
			
			this.player.playlist.onMetaData(onMetaData);
			this.player.playlist.onSeek(onSeek);
			this.player.playlist.onResized(onResized);
			
			
			sh = new Shape();
			sh.graphics.lineStyle(1, 0, 0.6);
			sh.graphics.beginFill(0x222222, 0.6);
			sh.graphics.moveTo(5, 5);
			sh.graphics.curveTo(0, 10, 10, 10);
			
			sp = new Sprite();
			sp.addChild(sh);
			
			tf = new TextField();
			tf.text = "widget";
			tf.textColor = 0xFFFFFF;
			this.player.onLoad(onMouseOver);
			this.player.onMouseOver(onMouseOver);
			this.player.onMouseOut(onMouseOut);
			
			model.dispatchOnLoad();
		}
		
		private function onMouseOver(event:PlayerEvent):void
		{
			addChild(sp);
		}
		
		private function onMouseOut(event:PlayerEvent):void
		{
			try 
			{
				removeChild(sp);
			}
			catch (err:Error)
			{
				
			}
		}
		
		private function onMetaData(event:ClipEvent):void
		{
			if (player.streamProvider.netStream)
				initCaptions();
		}
		
		private function initCaptions():void
		{
			captions = new Captions(true, config.animateCaptions);
			captions.setContainer(captionsContainer);
			captions.setStream(player.streamProvider.netStream);
			captions.setVideoRect(new Rectangle(0, 0, player.currentClip.width, player.currentClip.height));
			
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
		
		private function onSeek(event:ClipEvent):void
		{
			if (captions)
				captions.flush((player.streamProvider.netStream.time > 0 ? player.streamProvider.netStream.time : 0));
		}
		
		public function onResized(event:ClipEvent):void
		{
            resizeCaptionsToStage();
        }
		
		private function resizeCaptionsToStage():void
		{
			if (captions)
			{
				captions.setVideoRect(new Rectangle(0, 0, player.currentClip.width, player.currentClip.height));
				captions.flush();
				captionsContainer.addChild(new TextField());
			}
		}
	}
}