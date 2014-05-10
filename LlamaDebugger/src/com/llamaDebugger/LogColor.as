package com.fireflyLib.debug
{
    public class LogColor
    {
		//u can change the color.
        public static var DEBUG:uint 	= 0xDDDDDD;
        public static var INFO:uint 	= 0xBBBBBB;
        public static var WARN:uint 	= 0xFF6600;
        public static var ERROR:uint 	= 0xFF0000;
        public static var TRACE:uint 	= 0xFFFFFF;
        public static var CMD:uint 	= 0x00DD00;

        public static function getColor(logType:uint):uint
        {
            switch(logType)
            {
                case Logger.DEBUG:
                    return DEBUG;
					
                case Logger.INFO:
                    return INFO;
					
                case Logger.WARNING:
                    return WARN;
					
                case Logger.ERROR:
                    return ERROR;
					
                case Logger.TRACE:
                    return TRACE;
					
                case Logger.CMD:
                    return CMD;

                default:
                    return TRACE;
            }
        }
    }
}