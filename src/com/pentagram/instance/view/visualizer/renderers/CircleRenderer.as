package com.pentagram.instance.view.visualizer.renderers
{
	import com.greensock.TweenNano;
	import com.pentagram.model.vo.DataRow;
	
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.events.CloseEvent;
	import mx.events.ToolTipEvent;
	import mx.graphics.IStroke;
	import mx.graphics.Stroke;
	import mx.managers.PopUpManager;
	
	public class CircleRenderer extends BaseRenderer
	{

		private var _hovered:Boolean = false; 
		private var _mouseCaptured:Boolean = false;  
		private var info:RendererInfo;
		private var infoVisible:Boolean = false;
		public function CircleRenderer():void {
			super();
			
			textFormat = new TextFormat();
			textFormat.font = "FlamaBookMx2";
			textFormat.size = 12;
			textFormat.color = _textColor;
			textFormat.align="left";
			
			label = new TextField();
			label.selectable = false;
//			label.border = true;
//			label.borderColor = 0xff0000;
			label.embedFonts = true;
			label.mouseEnabled = false;
			label.defaultTextFormat = textFormat;
			label.width = 30; label.height = 20;	
			this.addChild(label);
			
			addEventListener(MouseEvent.ROLL_OVER, mouseEventHandler);
			addEventListener(MouseEvent.ROLL_OUT, mouseEventHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
			addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
			addEventListener(MouseEvent.CLICK, mouseEventHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			this.toolTip = " ";
			this.addEventListener(ToolTipEvent.TOOL_TIP_CREATE,createToolTip);
			this.addEventListener(ToolTipEvent.TOOL_TIP_SHOW,positionTip);
		}
		
		public const DEFAULT_GRADIENTTYPE:String = GradientType.LINEAR;
		public const FILL_ALPHAS:Array = [0.8,0.8];
		public const FILL_RATIO:Array = [0,255];

		protected var stateFlag:Boolean = false;
		protected var dirtyFlag:Boolean = false;
		protected var dirtyCoordFlag:Boolean = false;
		
	
	
		override public function set data(d:DataRow):void { 
			_data = d; 
			fillColor = textColor = d.country.region.color;
		}
		public function set state(value:Boolean):void {
			if(value && !stateFlag)
				dirtyFlag = true;
			stateFlag = value;
			this.invalidateDisplayList();
		}
		public function get state():Boolean {
			return stateFlag;
		}

		override public function dirty():void {
			dirtyFlag = true;
			this.invalidateDisplayList();
		}
		public function dirtyCoordinates():void {
			dirtyCoordFlag = true;
			this.invalidateProperties();
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(dirtyCoordFlag)
				updateCoordinates();
		}
		protected function updateCoordinates():void {
			//throw exception
		}
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			if(dirtyFlag && stateFlag)
				draw();
			else if(!stateFlag) {
				this.graphics.clear();
				if(label)
					label.visible = false;
			}
		}
		protected function draw():void {
			dirtyFlag = false;
			graphics.clear();
			var stroke:IStroke = new Stroke(_fillColor,1,1);
			stroke.apply(graphics,null,null);
			var matr:Matrix = new Matrix();
			matr.createGradientBox(_radius*2, _radius*2, Math.PI/1.7, 0, 0);
			graphics.beginGradientFill(DEFAULT_GRADIENTTYPE,[_fillColor,_fillColor],[_fillAlpha,_fillAlpha],FILL_RATIO,matr)			
			graphics.drawCircle(0, 0, _radius);
			graphics.endFill();	
			
//			graphics.lineStyle(1,0,1);
//			graphics.beginFill(0xff0000,1);
//			graphics.moveTo(-_radius,0);
//			graphics.drawRect(-_radius,0,_radius*2,1);
			
//			graphics.moveTo(0,-_radius);
//			graphics.drawRect(0,-_radius,1,_radius*2);
//			graphics.endFill();
			//textFormat.color = _fillColor;
			
			textFormat.color = _textColor;			
			label.text = _data.country.shortname
			label.x = -label.textWidth/2;
			label.y = -label.textHeight/2;
			label.width = label.textWidth+4;
			label.height = label.textHeight+4;	
			label.defaultTextFormat = textFormat;
			label.visible = true;
			if(this.alpha == 0) {
				TweenNano.to(this,0.5,{delay:1,alpha:1});
				
			}
		}	
		protected function createToolTip(event:ToolTipEvent):void {
			var ptt:RendererTooltip = new RendererTooltip();
			ptt.bodyText = _data.country.shortname;
			event.toolTip = ptt;	
			var pt:Point = this.localToGlobal(new Point(x,y));
			ptt.x = pt.x;
			ptt.y = pt.y;
			//trace(x,y,width,height);
		}
		
		private function positionTip(event:ToolTipEvent):void{
//			event.toolTip.x=event.currentTarget.x + event.currentTarget.width + 10;
//			event.toolTip.y=event.currentTarget.y;
		}
		protected function mouseEventHandler(event:Event):void {
			var mouseEvent:MouseEvent = event as MouseEvent;
			switch (event.type)
			{
				case MouseEvent.ROLL_OVER:
				{
					//popUp.displayPopUp = true;	
					break;
				}
					
				case MouseEvent.ROLL_OUT:
				{	
					//trace(this.hitTestPoint(this.parentApplication.mouseX,this.parentApplication.mouseY,true),popUp.popUp.hitTestPoint(this.parentApplication.mouseX,this.parentApplication.mouseY,true));
					//var v1:Boolean = this.hitTestPoint(this.parentApplication.mouseX,this.parentApplication.mouseY,false);
//					var v2:Boolean = popUp.popUp.hitTestPoint(this.parentApplication.mouseX,this.parentApplication.mouseY,false);
//					if(!v2)
					//	popUp.displayPopUp = false;
					break;
				}
					
				case MouseEvent.MOUSE_DOWN:
				{
					break;
				}
					
				case MouseEvent.MOUSE_UP:
				{

					break;
				}
				case MouseEvent.CLICK:
				{
					if(!infoVisible) {
						info = new RendererInfo();
						info.bodyText = _data.country.name;
						info.addEventListener(CloseEvent.CLOSE,handleInfoClose,false,0,true);
						var pt:Point = this.parent.localToGlobal(new Point(x,y));
						info.x = pt.x+radius; info.y = pt.y +60;
						PopUpManager.addPopUp(info, this.parent, false);
						infoVisible = true;
					}
				}
			}
		}
		private function handleInfoClose(event:CloseEvent):void {
			infoVisible = false;
		}
		private function addedToStageHandler(event:Event):void {

		}
				
	}
}