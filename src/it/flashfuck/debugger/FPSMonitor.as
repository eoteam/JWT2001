/**
* @author Piergiorgio Niero - www.flashfuck.it
*/
package it.flashfuck.debugger
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	
	public class FPSMonitor extends Sprite
	{
		private var _btnGC:Sprite;
		private var _fpstxt:TextField;
		private var _tmpfps:Number;
		private var _fps:Number;
		private var _ms:int;
		private var _time:int;
		private var _mem:Number;
		private var _monitor:Bitmap;
		private var _m:BitmapData
		
		private var _playerVersion:String;
		private var _1024:Number;
		
		private const MONITOR_MEM_MAX:uint=100;//mb
		private const MONITOR_FPS_MAX:uint=100
		
		private const MONITOR_H:uint = 100;
		private const MONITOR_W:uint = 100;
		
		private const MONITOR_BG_COLOR:uint = 0x99333333;
		private const MONITOR_FPS_COLOR:uint = 0xFFFFFFFF;
		private const MONITOR_MEM_COLOR:uint = 0xFF000000;
		private const MONITOR_TXT_COLOR:uint = 0xFFFFFF;
		
		
		public function FPSMonitor()
		{
			super();
			setupui();
			initMonitor();
		}
		
		private function setupui():void
		{
			_m = new BitmapData(MONITOR_W,MONITOR_H,true,MONITOR_BG_COLOR);
			_monitor = new Bitmap(_m);
			_monitor.y=40;
			addChild(_monitor);
			_fpstxt = new TextField();
			var txtf:TextFormat = new TextFormat();
			txtf.color = MONITOR_TXT_COLOR;
			txtf.font = "Verdana";
			txtf.size = 10;
			_fpstxt.defaultTextFormat = txtf;
			_fpstxt.autoSize = "left";
			_fpstxt.selectable=false;
			addChild(_fpstxt);
			
			_btnGC = new Sprite();
			with(_btnGC.graphics){
				beginFill(MONITOR_BG_COLOR,.5);
				drawRect(0,0,MONITOR_W,20);
				endFill();
			}
			var gcTxt:TextField = new TextField();
			gcTxt.defaultTextFormat = txtf;
			gcTxt.text="Run System.gc()";
			gcTxt.autoSize = "left";
			gcTxt.selectable=false;
			gcTxt.x = (MONITOR_W-gcTxt.width)*.5;
			gcTxt.y = (_btnGC.height-gcTxt.height)*.5;
			_btnGC.mouseChildren=false;
			_btnGC.buttonMode=true;
			_btnGC.addChild(gcTxt);
			_btnGC.y = _monitor.y+MONITOR_H;
			addChild(_btnGC);
			
		}
		
		private function initMonitor():void
		{
			_playerVersion = "("+Capabilities.playerType+") "+Capabilities.version+" debug:"+Capabilities.isDebugger;
			_1024 = 1/1024;
			_ms=getTimer();
			_fps=0;
			_tmpfps=0;
			addEventListener(Event.ENTER_FRAME,monitorFPS);
			_btnGC.addEventListener(MouseEvent.CLICK,runGC);
		}
		
		private function runGC(e:MouseEvent=null):void
		{
			System.gc();
		}
		
		private function monitorFPS(e:Event):void
		{
			_time = getTimer()-1000;
			if(_time>_ms){
				_fps=_tmpfps+(_tmpfps*.001*(_time-_ms));
				_ms=getTimer();
				_tmpfps=0;
			}else{
				_tmpfps++;
			}
			_mem = System.totalMemory*_1024*.001;
			_m.scroll(1,0);
			_m.setPixel32(1,MONITOR_H-(_fps/MONITOR_FPS_MAX*MONITOR_H),MONITOR_FPS_COLOR);
			_m.setPixel32(1,MONITOR_H-(_mem/MONITOR_MEM_MAX*MONITOR_H),MONITOR_MEM_COLOR);
			_fpstxt.text=_playerVersion+"\nFPS: "+_fps+"\nMEM: "+_mem.toString().substr(0,5);
		}
		
		
		
	}
}