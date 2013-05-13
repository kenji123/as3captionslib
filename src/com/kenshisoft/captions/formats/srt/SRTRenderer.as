package com.kenshisoft.captions.formats.srt
{
	import com.kenshisoft.captions.FontClass;
	import com.kenshisoft.captions.formats.ICaption;
	import com.kenshisoft.captions.formats.IParser;
	import com.kenshisoft.captions.formats.IRenderer;
	import com.kenshisoft.captions.models.IEvent;
	import com.kenshisoft.captions.models.ISubtitle;
	import com.kenshisoft.captions.models.srt.SRTEvent;
	import com.kenshisoft.captions.models.srt.SRTSubtitle;
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author 
	 */
	public class SRTRenderer implements IRenderer
	{
		private var _parser:SRTParser;
		
		public function SRTRenderer()
		{
			super();
			
			_parser = new SRTParser();
		}
		
		public function render(subtitle_:ISubtitle, event_:IEvent, videoRect:Rectangle, container:DisplayObjectContainer, time:Number = -1, animate:Boolean = true, caption_:ICaption = null):ICaption
		{
			var subtitle:SRTSubtitle = SRTSubtitle(subtitle_);
			var event:SRTEvent = SRTEvent(event_);
			
			var caption:SRTCaption = new SRTCaption(event);
			
			var textFormat:TextFormat = new TextFormat();
            textFormat.size = 20;
            textFormat.font = "Arial";
			
			var textField:TextField = new TextField();
			textField.defaultTextFormat = textFormat;
			textField.blendMode = BlendMode.LAYER;
            textField.text = event.text;
            textField.antiAliasType = AntiAliasType.ADVANCED;
			textField.x = videoRect.x;
			textField.y = videoRect.bottom - textField.height;
			
			var renderSprite:Sprite = new Sprite();
			renderSprite.addChild(textField);
			
			renderSprite.cacheAsBitmap = true;
			caption.renderSprite = renderSprite;
			
			return caption;
		}
		
		public function add(caption_:ICaption, captionsOnDisplay_:Vector.<ICaption>, container:DisplayObjectContainer, rerender:Boolean = false):void
		{
			var caption:SRTCaption = SRTCaption(caption_);
			var captionsOnDisplay:Vector.<SRTCaption> = Vector.<SRTCaption>(captionsOnDisplay_);
			
			// let's keep "newer" captions at the front
			var insertAt:int = -1;
			
			for (var c:int; c < captionsOnDisplay.length; c++)
			{
				if (captionsOnDisplay[c].event.startSeconds > caption.event.startSeconds)
					try { insertAt = container.getChildIndex(captionsOnDisplay[c].renderSprite) - 1; } catch (error:Error) { }
			}
			
			try { insertAt == -1 ? container.addChild(caption.renderSprite) : container.addChildAt(caption.renderSprite, insertAt); } catch (error:Error) { }
		}
		
		public function remove(caption_:ICaption, container:DisplayObjectContainer):void
		{
			try { container.removeChild(caption_.renderSprite); } catch (error:Error) { }
		}
		
		public function get parser():IParser
		{
			return _parser;
		}
	}
}
