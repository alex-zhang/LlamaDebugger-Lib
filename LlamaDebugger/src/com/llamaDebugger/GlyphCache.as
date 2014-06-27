package com.llamaDebugger
{
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    /**
     * Helper class to cache glyphs as bitmaps and draw them fast, with color.
     * @author beng
     * 
     */
    public class GlyphCache
    {
		protected static const mHelperTextField:TextField = new TextField();mHelperTextField.autoSize = TextFieldAutoSize.LEFT;
//		mHelperTextField.border = true;
		protected static const mHelperTextFieldMatrix:Matrix = new Matrix(1, 0, 0, 1, -2, -2);
		
		protected const mGlyphCache:Array = [];
		protected const mColorCache:Array = [];
		
        public function GlyphCache(textFormat:TextFormat)
        {
            // Set up the text field.
			mHelperTextField.defaultTextFormat = textFormat;
        }
        
        public function drawLineToBitmap(line:String, x:int, y:int, color:uint, renderTarget:BitmapData):int
        {
            // Get the color bitmap.
            if(!mColorCache[color])
                mColorCache[color] = new BitmapData(20, 20, false, color);
			
            const colorBitmap:BitmapData = mColorCache[color] as BitmapData;

            // Keep track of current pos.
            var curPos:Point = new Point(x, y);
            var linesConsumed:int = 1;
            
            // Get each character.
            const glyphCount:int = line.length;
            for(var i:int = 0; i < glyphCount; i++)
            {
                const char:int = line.charCodeAt(i);
                
                // Special cases...
                if(char == 10)
                {
                    // New line!
                    curPos.x = x;
                    curPos.y += getLineHeight();
                    linesConsumed++;
                    continue;
                }

                // Draw the glyph.
                const glyph:Glyph = getGlyph(char);
                renderTarget.copyPixels(colorBitmap, glyph.rect, curPos, glyph.bitmap, null, true);
                
                // Update position.
                curPos.x += glyph.rect.width;
            }
            
            return linesConsumed;
        }
        
        protected function getGlyph(charCode:int):Glyph
        {
            if(mGlyphCache[charCode] == null)
            {
                // Generate glyph.
                var newGlyph:Glyph = new Glyph();
                mHelperTextField.text = String.fromCharCode(charCode);
                newGlyph.bitmap = new BitmapData(mHelperTextField.width - 4, mHelperTextField.height - 4, true, 0x0);
                newGlyph.bitmap.draw(mHelperTextField, mHelperTextFieldMatrix);
				
                newGlyph.rect = newGlyph.bitmap.rect;
                
                // Store it in cache.
                mGlyphCache[charCode] = newGlyph;
            }
            
            return mGlyphCache[charCode] as Glyph;
        }
        
        public function getLineHeight():int
        {
            // Do some tall characters.
            mHelperTextField.text = "HPI";
            return mHelperTextField.height - 4;
        }
    }
}

import flash.display.BitmapData;
import flash.geom.Rectangle;

class Glyph
{
    public var rect:Rectangle;
    public var bitmap:BitmapData;
}
