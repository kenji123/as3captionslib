# AS3 Captions (as3captionslib)

AS3 Captions is an AS3 library for various subtitle formats, that allows developers to easily make their flash based video accessible.

## Supported Formats

 - Advanced Substation Alpha (*.ass)
 - SubRipper/SubRip (*.srt)
 - CrunchyRoll (*.xml)

## See It In Action

 - [Flowplayer/JW Player plugin demo] (a bit outdated)

  [Flowplayer/JW Player plugin demo]: http://www.kenshisoft.com/projects-resos/as3captionslib/

## Dependencies

 - [as3-signals] (already included)

  [as3-signals]: https://github.com/robertpenner/as3-signals

## Formats

### Advanced Substation Alpha

Unsupported tags:

 - \\(i)clip
 - \k (and all other variants)
 - \fe
 - \pbo
 - \p

Unsupported effects:

 - Scroll
 - Banner

### SubRipper/SubRip

 - Specific positioning in not yet supported. (X1:left X2:right Y1:top Y2:bottom)
 - The html <font\> tag with the 'color' attribute is not yet supported.

### CrunchyRoll

Fully supported based on subtitles tested so far.

## Basic Usage Examples

### Flashvar config

```
{
    "captions": [
        {
            "url": "subtitles/subtitle.ass",
            "format": "ASS",
            "language": "en",
            "defaultCaption": true,
            "fonts": [
                {
                    "url": "fonts/ImpressBT.swf",
                    "swfClass": "ImpressBT",
                    "fontClasses": [
                        {
                            "className": "IMPRESSBT",
                            "fontFamily": "Impress BT",
                            "aliases": [
                                "Impress BT"
                            ]
                        }
                    ]
                }
            ]
        }
    ],
    "captionsEnabled": true,
    "captionsAnimated": true
}
```

### Loading the config

```
var config:Config = new Config(JSON.parse(stage.loaderInfo.parameters.args));
```

### Loading a subtitle

```
var captionsContainer:Sprite = new Sprite();
addChild(captionsContainer);

var captions:Captions = new Captions(config.captionsEnabled, config.captionsAnimated);
captions.setContainer(captionsContainer);
captions.setStream(netStream); // initialized NetStream instance of the video
captions.setVideoRect(new Rectangle(video.x, video.y, video.width, video.height)); // position of the video on the stage

var currentSubtitle:CaptionConfig = config.getDefaultCaption();
captions.loadCaptions(currentSubtitle.format, currentSubtitle.url);
```

## Integration with Existing Flash Players

AS3 Captions can be integrated into any flash video player natively or as a plugin via an API for example, and only requires the NetStream object of the video being played back.

Flowplayer and JW Player are already supported. There are example implementations available under the [plugins folder]. Checkout the [Flowplayer/JW Player plugin demo] to see it in action.

  [plugins folder]: https://github.com/kenji123/as3captionslib/tree/master/plugins

## Fonts

Advanced Substation Alpha and CrunchyRoll use external fonts, and as3captionslib supports fonts as well. A built-in font loader is available. See the below example on how to load multiple fonts.

### Compiling fonts

```
//TODO:
```

### Creating flashvar config based on compiled SWF font info

```
//TODO:
```

### Loading multiple fonts

```
var config:Config = new Config(JSON.parse(_stage.loaderInfo.parameters.args));
var currentSubtitle:CaptionConfig = config.getDefaultCaption();

var captions:Captions = new Captions(config.captionsEnabled, config.captionsAnimated);
captions.loadFontSwf(currentSubtitle.fonts[0]);

public function Player()
{
	super();
    
    loadFonts();
}

private function loadFonts():void
{
	if (currentSubtitle.fonts.length < 1) return;
	
	for (var k:int = 0, l:int = currentSubtitle.fonts.length; k < l; k++)
	{
		if (!currentSubtitle.fonts[k].registered)
		{
			captions.loadFontSwf(currentSubtitle.fonts[k]);
			return;
		}
	}
}

private function onFontsRegistered(event:FontConfig):void
{
	for (var i:int = 0, j:int = currentSubtitle.fonts.length; i < j; i++)
	{
		if (currentSubtitle.fonts[i].url == event.url)
			currentSubtitle.fonts[i].registered = true;
	}
	
	loadFonts();
}
```

## More Examples

### Adding delay to captions
```
var captions:Captions = new Captions(config.captionsEnabled, config.captionsAnimated);
captions.setTimeShift(0.5); // delay by half a second
```

```
//TODO:
```

## Limitations

There are some limitations due to Flash's architecture.

### Fonts

Fonts have to be loaded from a pre-compiled swf. Depending on how many fonts are used and how large each font is (especially unicode fonts), the larger the file size of the font swf will be that needs to be loaded.

Let's say your using external fonts, and you have a few lines in italics. If one the fonts you use doesn't include the italic font, flash will render the text normaly. Which is correct. When using device fonts (of the user's system. e.g. Windows), the system actually returns modified glyphs to compensate if no italic or bold glyphs are available for that font. An italic hack has been added to AS3 Captions to skew the text when italic glyphs aren't available. However, there is no hack for bold text.

Flash/AS3 does not let you set font height exclusively. That, along with inconsistent, poor font metric capabilities, and drastic differences between DefineFont3 and DefineFont4, complicates things even more. DefineFont3 embeds glyph data into the compiled swf along with font metrics. This is not so with DefineFont4. Thus, a font size set for a regular TextField is visually different (font metrics and all) from that of a TextLine, especially from font to font.

### Time and Frame Accuracy

Captions are not "frame" accurate, because AS3 Captions is not a video filter.
Animated and effect features of *.ass captions eat CPU as the caption needs to be rendered each frame and added to the Stage Display list. If Adobe introduces the transparent property to Stage3D in the future, perhaps a StageVideo+Stage3D combination can be used.
