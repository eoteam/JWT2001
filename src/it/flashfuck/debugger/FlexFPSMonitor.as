/**
* @author Piergiorgio Niero - www.flashfuck.it
*/
package it.flashfuck.debugger
{
	import flash.display.BlendMode;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;

	public class FlexFPSMonitor extends UIComponent
	{
		private var _isDragging:Boolean=false;
		private var _fps:FPSMonitor;
		
		public function FlexFPSMonitor()
		{
			super();
			_fps = new FPSMonitor();
			_fps.blendMode = BlendMode.INVERT;
			this.addChild(_fps);
			this.addEventListener(MouseEvent.MOUSE_DOWN,_startDrag);
			this.addEventListener(MouseEvent.MOUSE_UP,_stopDrag);
		}
		
		private function _startDrag(e:MouseEvent):void
		{
			if(!_isDragging){
				
				this.startDrag();
				_isDragging=true;
			}
		}
		
		private function _stopDrag(e:MouseEvent):void
		{
			if(_isDragging){
				this.stopDrag();
				_isDragging=false;
			}
		}

	}
}