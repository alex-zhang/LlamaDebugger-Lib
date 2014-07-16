package com.llamaDebugger
{
    import com.fireflyLib.utils.GlobalPropertyBag;
    import com.fireflyLib.utils.StringUtil;

    import flash.external.ExternalInterface;
    import flash.system.Capabilities;
    import flash.system.System;
    import flash.utils.getDefinitionByName;

    /**
     * Process simple text mCommands from the user. Useful for debugging.
     */
    public class Console
    {
        /**
         * The mCommands, indexed by name.
         */
        protected static var mCommands:Object = {};
        
        /**
         * Alphabetically ordered list of mCommands.
         */
        protected static var mCommandList:Array = [];
        protected static var mCommandListOrdered:Boolean = false;
        
        protected static var mHotKeyCode:uint = 192;//~
        
        protected static var mStats:Stats;
		
        public static var showStackTrace:Boolean = false;
        
        
        /**
         * Register a command which the user can execute via the console.
         *
         * <p>Arguments are parsed and cast to match the arguments in the user's
         * function. Command names must be alphanumeric plus underscore with no
         * spaces.</p>
         *
         * @param name The name of the command as it will be typed by the user. No spaces.
         * @param callback The function that will be called. Can be anonymous.
         * @param docs A description of what the command does, its arguments, etc.
         *
         */
        public static function registerCommand(name:String, callback:Function, docs:String = null):void
        {
            // Sanity checks.
            if (callback == null)
			{
				Logger.error("Command '" + name + "' has no callback!", "registerCommand");
			}
            
            if (!name || name.length == 0)
			{
				Logger.error("Command has no name!", "registerCommand");
			}
            
            if (name.indexOf(" ") != -1)
			{
				Logger.error("Command '" + name + "' has a space in it, it will not work.", "registerCommand");
			}

//			name = name.toLowerCase();
			
            // Fill in description.
            var c:ConsoleCommand = new ConsoleCommand();
            c.name = name;
            c.callback = callback;
            c.docs = docs;
            
            if (mCommands[name])
			{
				Logger.warn("Replacing existing command '" + name + "'.", "registerCommand");
			}

            // Set it.
            mCommands[name] = c;
            
            // Update the list.
            mCommandList.push(c);
            mCommandListOrdered = false;
        }
        
        /**
         * @return An alphabetically sorted list of all the console mCommands.
         */
        public static function getCommandList():Array
        {
            ensuremCommandsOrdered();
            
            return mCommandList;
        }
        
        /**
         * Take a line of console input and process it, executing any command.
         * @param line String to parse for command.
         */
        public static function processLine(line:String):void
        {
            // Make sure everything is in order.
            ensuremCommandsOrdered();
            
            // Match Tokens, this allows for text to be split by spaces excluding spaces between quotes.
            // TODO Allow escaping of quotes
            var pattern:RegExp = /[^\s"']+|"[^"]*"|'[^']*'/g;
            var args:Array = [];
            var test:Object = {};
            while (test)
            {
                test = pattern.exec(line);
                if (test)
                {
                    var str:String = test[0];
                    str = StringUtil.trimChar(str, "'");
                    str = StringUtil.trimChar(str, "\"");
                    args.push(str);	// If no more matches can be found, test will be null
                }
            }
            
            // Look up the command.
            if(args.length == 0) return;
			
            var potentialCommand:ConsoleCommand = mCommands[args[0].toString()];
            
            if(!potentialCommand)
            {
				Logger.warn("No such command '" + args[0].toString() + "'!", "processLine");
                return;
            }
            
            // Now call the command.
            try
            {
                potentialCommand.callback.apply(null, args.slice(1));
            }
            catch(e:Error)
            {
                var errorStr:String = "Error: " + e.toString();
				
                if (showStackTrace)
                {
                    errorStr += " - " + e.getStackTrace();
                }

				Logger.error(errorStr, args[0]);
            }
        }
        
        /**
         * Internal initialization, this will get called on its own.
         */
        public static function init():void
        {
            /*** THESE ARE THE DEFAULT CONSOLE mCommands ***/
            registerCommand("help", function(prefix:String = null):void
            {
                // Get mCommands in alphabetical order.
                ensuremCommandsOrdered();
                
				Logger.customPrint("Keyboard shortcuts: ");
				Logger.customPrint("[SHIFT]-TAB - Cycle through autocompleted mCommands.");
				Logger.customPrint("PGUP/PGDN   - Page log view up/down a page.");
				Logger.customPrint("");
                
                // Display results.
				Logger.customPrint("Commands:");
                for (var i:int = 0; i < mCommandList.length; i++)
                {
                    var cc:ConsoleCommand = mCommandList[i] as ConsoleCommand;
                    
                    // Do prefix filtering.
                    if (prefix && prefix.length > 0 && cc.name.substr(0, prefix.length) != prefix)
                        continue;
                    
					Logger.customPrint("   " + cc.name + " - " + (cc.docs ? cc.docs : ""));
                }
                
                // List input options.
            }, "[prefix] - List known mCommands, optionally filtering by prefix.");

            registerCommand("fps", function():void
            {
                if (!mStats)
                {
                    mStats = new Stats();
					GlobalPropertyBag.stage.addChild(mStats);
					Logger.customPrint("Enabled FPS display.");
                }
                else
                {
					GlobalPropertyBag.stage.removeChild(mStats);
                    mStats = null;
                    Logger.customPrint("Disabled FPS display.");
                }
            }, "Toggle an FPS/Memory usage indicator.");
            
            registerCommand("logLevel", function(level:int):void
            {
				Logger.logLevel = level;
				
                Logger.customPrint("Logger set to " + level);
            }, "Set Logger level output.");
            
			registerCommand("exit", function():void
			{
				if(Capabilities.playerType == "Desktop")
				{
                    getDefinitionByName("flash.desktop::NativeApplication").nativeApplication.exit();
				}
				else if(Capabilities.playerType == "StandAlone")
				{
					System.exit(0);
				}
				else if(Capabilities.playerType == "ActiveX" || Capabilities.playerType == "PlugIn")//web
				{
					if(ExternalInterface.available)
					{
						Logger.info("exit", ExternalInterface.call("window.close"));	
					}
					else
					{
						Logger.warn("exit", "ExternalInterface is not avaliable!");
					}
				}
			}, "Attempts to exit the application.");
        }
        
        protected static function ensuremCommandsOrdered():void
        {
            // Avoid extra work.
            if (mCommandListOrdered == true) return;
            
            // Register default mCommands.
            if (mCommands.help == null) init();
            
            // Note we are done.
            mCommandListOrdered = true;

            // Do the sort.
            mCommandList.sort(function(a:ConsoleCommand, b:ConsoleCommand):int
            {
                if (a.name > b.name)  return 1;
                else return -1;
            });
        }
        
//        protected static function generateIndent(indent:int):String
//        {
//            var str:String = "";
//            for(var i:int = 0; i < indent; i++)
//            {
//                // Add 2 spaces for indent
//                str += "  ";
//            }
//
//            return str;
//        }
        
        /**
         * The keycode to toggle the Console interface.
         */
        public static function set hotKeyCode(value:uint):void
        {
            Logger.customPrint("Setting hotKeyCode to: " + value);
            mHotKeyCode = value;
        }
        
        public static function get hotKeyCode():uint
        {
            return mHotKeyCode;
        }
    }
}

final class ConsoleCommand
{
    public var name:String;
    public var callback:Function;
    public var docs:String;
}