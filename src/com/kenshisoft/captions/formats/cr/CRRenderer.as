package com.kenshisoft.captions.formats.cr
{
	import com.kenshisoft.captions.FontClass;
	import com.kenshisoft.captions.formats.ICaption;
	import com.kenshisoft.captions.formats.IParser;
	import com.kenshisoft.captions.formats.IRenderer;
	import com.kenshisoft.captions.misc.Util;
	import com.kenshisoft.captions.models.cr.CREvent;
	import com.kenshisoft.captions.models.cr.CRStyle;
	import com.kenshisoft.captions.models.cr.CRSubtitleScript;
	import com.kenshisoft.captions.models.IEvent;
	import com.kenshisoft.captions.models.ISubtitle;
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author 
	 */
	public class CRRenderer implements IRenderer
	{
		private var _parser:CRParser;
		
		private var defaultHeight:int = 480;
		private var staticMultiplier:int = 2;
		private var calcHeight:Number;
		private var calcWidth:Number;
		
		public function CRRenderer()
		{
			super();
			
			_parser = new CRParser();
		}
		
		private function getGlowStrength(styleOutline:Number):Number
		{
            switch (styleOutline)
            {
				case 0:
					return 4;
				case 1:
					return 7;
				case 2:
					return 14;
				case 3:
					return 28;
				case 4:
                    return 7;
				default:
					return 1;
            }
        }
		
		private function getFilters(style:CRStyle):Array
		{
			var filters:Array = new Array();
            
            if (style.border_style != 1) // _-58._-0Q = 1
                return filters;
            
            var styleOutline:Number = style.outline;
            var glowStrength:Number = getGlowStrength(styleOutline);
            if (styleOutline > 0)
                filters.push(new GlowFilter(Util.removeAlpha(style.colours[2]), 1, styleOutline, styleOutline, glowStrength, BitmapFilterQuality.HIGH));
			
            if (style.shadow > 0)
            {
				var dropShadow:DropShadowFilter = new DropShadowFilter();
                dropShadow.distance = style.shadow;
                dropShadow.color = Util.removeAlpha(Util.removeAlpha(style.colours[3]));
                filters.push(dropShadow);
            }
			
            return filters;
        }
		
		private function getY(textField:TextField, event:CREvent, style:CRStyle):Number
		{
            switch (style.alignment)//unresolved jump//, , getAlignment()._-2J)
            {
				/*case _ -3J._ -1q: // top
					return (((calcHeight - textField.textHeight) / 2));
                case _-3J._-0P: // middle
					return (((((calcHeight + staticMultiplier) - textField.textHeight) - _ -t()) - textField.getLineMetrics(0).descent));
				case _-3J._-10: // bottom*/
                default:
                    return ((event.margin.bottom > 0 ? event.margin.bottom : style.margin.bottom) + style.outline) - staticMultiplier;
            }
        }
		
		public function render(subtitle_:ISubtitle, event_:IEvent, videoRect:Rectangle, container:DisplayObjectContainer, fontClasses:Vector.<FontClass>, time:Number = -1, animate:Boolean = true):ICaption
		{
			var subtitle:CRSubtitleScript = CRSubtitleScript(subtitle_);
			var event:CREvent = CREvent(event_);
			
			var style:CRStyle = _parser.getStyle(event.style, subtitle.styles);
			
			var caption:CRCaption = new CRCaption(event);
			
			calcHeight = subtitle.play_res_y > 0 ? subtitle.play_res_y : defaultHeight;
			calcWidth = Math.floor((calcHeight * videoRect.width) / videoRect.height);
            
			var textFormat:TextFormat = new TextFormat();
			//textFormat.font = getPreferredFont(_ -1g.style.font_name);
			textFormat.font = style.font_name;
			textFormat.size = style.font_size;
			textFormat.color = Util.removeAlpha(style.colours[0]);
			//textFormat.align = getAlignment()._-1a;
			textFormat.bold = style.bold;
			textFormat.italic = style.italic;
			textFormat.underline = style.underline;
			textFormat.leftMargin = (event.margin.left > 0 ? event.margin.left : style.margin.left) - style.outline;
			textFormat.rightMargin =  (event.margin.right > 0 ? event.margin.right : style.margin.right) - style.outline;
			
			var textField:TextField = new TextField();
			//var _local5:Object;
            //var _local6:TextFormat;
            //var _local7:String;
			textField.filters = getFilters(style);
			textField.defaultTextFormat = textFormat;
			textField.height = calcHeight;
			textField.width = calcWidth + (2 * staticMultiplier);
			textField.x = 0 - staticMultiplier;
			textField.blendMode = BlendMode.LAYER;
			//var _local2:_-5j = _-3W();
			//textField.text = _-0._-1();
            //textField.text = _-0._-8f();
			textField.text = event.text;
			//textField.wordWrap = _local2._-3c;
            //var _local3:Array = _-0.false();
            //var _local4:Number = 0;
            /*while (_local4 < _local3.length)
            {
                _local5 = _local3[_local4];
                _local6 = new TextFormat();
                for (_local7 in _local5)
                {
                    _local6[_local7] = _local5[_local7];
                };
                textField.setTextFormat(_local6, _local4, (_local4 + 1));
                _local4++;
            };*/
            //textField.embedFonts = isEveryFontEmbedded(_local1);
            //for (;!(textField.embedFonts);(textField.sharpness = -100), //unresolved jump
			//, (_local1.gridFitType = GridFitType.NONE), continue)
			textField.antiAliasType = AntiAliasType.ADVANCED;
			
			textField.y = getY(textField,event, style);
            //_-1Q = _-1J(textField);
            //var _local4:DisplayObjectContainer = _-6c(_-2z, _-53, _-5r, _-m);
            //addChild(_local4);
            //_tweens = _-32(_arg1);
            //_local4.addChild(textField);
            //_local4.addChild(_-1Q);
            //_-1Q.visible = false;
			
			var renderSprite:Sprite = new Sprite();
			renderSprite.addChild(textField);
			
			renderSprite.cacheAsBitmap = true;
			caption.renderSprite = renderSprite;
			
			return caption;
		}
		
		public function add(caption_:ICaption, captionsOnDisplay_:Vector.<ICaption>, container:DisplayObjectContainer):void
		{
			var caption:CRCaption = CRCaption(caption_);
			var captionsOnDisplay:Vector.<CRCaption> = Vector.<CRCaption>(captionsOnDisplay_);
			
			// let's keep "newer" captions at the front
			var insertAt:int = -1;
			
			for (var c:int; c < captionsOnDisplay.length; c++)
			{
				if (captionsOnDisplay[c].event.startSeconds > caption.event.startSeconds)
					try { insertAt = container.getChildIndex(captionsOnDisplay[c].renderSprite) - 1; } catch (error:Error) { }
			}
			
			try { insertAt == -1 ? container.addChild(caption.renderSprite) : container.addChildAt(caption.renderSprite, insertAt); } catch (error:Error) { }
		}
		
		public function remove(caption:ICaption, container:DisplayObjectContainer):void
		{
			try { container.removeChild(caption.renderSprite); } catch (error:Error) { }
		}
		
		public function get parser():IParser
		{
			return _parser;
		}
	}
}
