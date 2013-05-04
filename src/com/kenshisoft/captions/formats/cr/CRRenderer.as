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
	import flash.text.TextFormatAlign;
	
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
		
		public static const BOTTOM:String = TextFormatAlign.END;
		public static const MIDDLE:String = TextFormatAlign.JUSTIFY;
		public static const TOP:String = TextFormatAlign.START;
		public static const LEFT:String = TextFormatAlign.LEFT;
		public static const CENTER:String = TextFormatAlign.CENTER;
		public static const RIGHT:String = TextFormatAlign.RIGHT;
		
		public static const BOTTOM_LEFT:Array = [1, 1, BOTTOM, LEFT];
		public static const BOTTOM_CENTER:Array = [2, 2, BOTTOM, CENTER];
		public static const BOTTOM_RIGHT:Array = [3, 3, BOTTOM, RIGHT];
        public static const MIDDLE_LEFT:Array = [4, 9, MIDDLE, LEFT];
        public static const MIDDLE_CENTER:Array = [5, 10, MIDDLE, CENTER];
		public static const MIDDLE_RIGHT:Array = [6, 11, MIDDLE, RIGHT];
		public static const TOP_LEFT:Array = [7, 5, TOP, LEFT];
        public static const TOP_CENTER:Array = [8, 6, TOP, CENTER];
        public static const TOP_RIGHT:Array = [9, 7, TOP, RIGHT];
		
		public static const WRAP1:Array = [0, true, true];
        public static const WRAP2:Array = [1, true, true];
        public static const NONE:Array = [2, false, false];
		public static const WRAP3:Array = [3, true, true];
        
		public function CRRenderer()
		{
			super();
			
			_parser = new CRParser();
		}
		
		private function getWrapStyle(subtitle:CRSubtitleScript):Array //TODO: do parse() text, then FIXME
		{
			var wrapStyles:Array = [WRAP1, WRAP2, NONE, WRAP3];
			
			for (var i:int; i < wrapStyles.length; i++)
            {
                if (wrapStyles[i][0] == subtitle.wrap_style)
                {
                    return wrapStyles[i];
                }
            }
			
            return null;
		}
		
		private function getAlignment(style:CRStyle):Array
		{
			var alignments:Array = [BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT, MIDDLE_LEFT, MIDDLE_CENTER, MIDDLE_RIGHT, TOP_LEFT, TOP_CENTER, TOP_RIGHT];
			
			for (var i:int; i < alignments.length; i++)
            {
                if (alignments[i][0] == style.alignment)
                {
                    return alignments[i];
                }
            }
			
            return null;
		}
		
		private function getGlowStrength(styleOutline:Number):Number
		{
            switch (styleOutline)
            {
				case 0:
					return 1;
				case 1:
					return 4;
				case 3:
					return 14;
				case 4:
                    return 28;
				case 2:
				default:
					return 7;
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
			var t:int = (event.margin.bottom > 0 ? event.margin.bottom : style.margin.bottom) + style.outline;
			
            switch (getAlignment(style)[2])
            {
				case TOP:
					return t - staticMultiplier;
                case MIDDLE:
					return (calcHeight - textField.textHeight) / 2;
				case BOTTOM:
                default:
                    return (((calcHeight + staticMultiplier) - textField.textHeight) - t) - textField.getLineMetrics(0).descent;
            }
        }
		
		public function render(subtitle_:ISubtitle, event_:IEvent, videoRect:Rectangle, container:DisplayObjectContainer, fontClasses:Vector.<FontClass>, time:Number = -1, animate:Boolean = true):ICaption
		{
			var subtitle:CRSubtitleScript = CRSubtitleScript(subtitle_);
			var event:CREvent = CREvent(event_);
			
			var style:CRStyle = _parser.getStyle(event.style, subtitle.styles).copy();
			
			var caption:CRCaption = new CRCaption(event);
			
			var scaleX:Number = subtitle.play_res_x > 0 ? (1.0 * videoRect.width / subtitle.play_res_x) : 1.0;
			var scaleY:Number = subtitle.play_res_y > 0 ? (1.0 * videoRect.height / subtitle.play_res_y) : 1.0;
			
			calcHeight = (subtitle.play_res_y > 0 ? subtitle.play_res_y : defaultHeight) * scaleX;
			calcWidth = (Math.floor((calcHeight * videoRect.width) / videoRect.height));
			
			style.font_size *= scaleY;
			style.outline *= scaleY;
			style.shadow *= scaleY;
			
			var textFormat:TextFormat = new TextFormat();
			//textFormat.font = getPreferredFont(_ -1g.style.font_name);
			textFormat.font = style.font_name;
			textFormat.size = style.font_size;
			textFormat.color = Util.removeAlpha(style.colours[0]);
			textFormat.align = getAlignment(style)[3];
			textFormat.bold = style.bold;
			textFormat.italic = style.italic;
			textFormat.underline = style.underline;
			textFormat.leftMargin = (event.margin.left > 0 ? event.margin.left : style.margin.left) - style.outline;
			textFormat.rightMargin = (event.margin.right > 0 ? event.margin.right : style.margin.right) - style.outline;
			
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
			var wrapStyle:Array = getWrapStyle(subtitle);
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
