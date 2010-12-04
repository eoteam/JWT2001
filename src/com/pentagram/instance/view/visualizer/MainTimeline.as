package com.pentagram.instance.view.visualizer
{
	import __AS3__.vec.*;
	import com.nodename.geom.*;
	import fl.controls.*;
	import flash.display.*;
	import flash.events.*;
	
	dynamic public class MainTimeline extends MovieClip
	{
		public var BUTTON:Button;
		public var circles:Vector.<Circle>;
		public var MODE:int;
		public var ok:int;
		public var i:int;
		public var j:int;
		public var C:Circle;
		public var d2:Number;
		public var dx:Number;
		public var dy:Number;
		public var bd:BitmapData;
		public var b:Bitmap;
		public var S:Sprite;
		public var G:Graphics;
		public var t:int;
		public var t2:int;
		public var cmode:int;
		
		public function MainTimeline()
		{
			addFrameScript(0, this.frame1);
			this.__setProp_BUTTON_Scene1_Layer1_0();
			return;
		}// end function
		
		public function handler(event:Event) : void
		{
			this.j = 0;
			while (this.j < 10)
			{
				
				var _loc_2:String = this;
				var _loc_3:* = this.t + 1;
				_loc_2.t = _loc_3;
				if (this.t > 6000)
				{
					stage.removeEventListener(Event.ENTER_FRAME, this.handler);
				}
				if (this.MODE == 0)
				{
					this.ok = 0;
					this.t2 = 0;
					while (this.ok == 0)
					{
						
						var _loc_2:String = this;
						var _loc_3:* = this.t2 + 1;
						_loc_2.t2 = _loc_3;
						this.G.clear();
						this.G.lineStyle(0.1, this.getC(this.cmode));
						this.C = new Circle(Math.random() * 1100, Math.random() * 800, 1);
						this.ok = 1;
						this.i = 0;
						while (this.i < this.circles.length)
						{
							
							this.d2 = this.C.radius + this.circles[this.i].radius + 4;
							if (this.cmode == 5)
							{
								this.d2 = this.d2 - 4;
							}
							this.dx = this.C.center.x - this.circles[this.i].center.x;
							this.dy = this.C.center.y - this.circles[this.i].center.y;
							if (this.dx * this.dx + this.dy * this.dy <= this.d2 * this.d2)
							{
								this.ok = 0;
							}
							var _loc_2:String = this;
							var _loc_3:* = this.i + 1;
							_loc_2.i = _loc_3;
						}
						if (this.t2 > 1000)
						{
							this.ok = 1;
						}
					}
					if (this.t2 <= 1000)
					{
						this.circles.push(this.C);
						this.MODE = 1;
					}
				}
				else if (this.MODE == 1)
				{
					this.C = this.circles[(this.circles.length - 1)];
					(this.C.radius + 1);
					this.G.clear();
					this.G.lineStyle(0.1, this.getC(this.cmode));
					if (this.cmode == 3)
					{
						this.G.beginFill(255, 0.5);
					}
					if (this.cmode == 4)
					{
						this.G.beginFill(Math.random() * 16777215, 1);
					}
					if (this.cmode == 5)
					{
						this.G.beginFill(4473924);
					}
					this.G.drawCircle(this.C.center.x, this.C.center.y, this.C.radius);
					if (this.cmode == 3 || this.cmode == 4 || this.cmode == 5)
					{
						this.G.endFill();
					}
					this.i = 0;
					while (this.i < (this.circles.length - 1))
					{
						
						this.dx = this.C.center.x - this.circles[this.i].center.x;
						this.dy = this.C.center.y - this.circles[this.i].center.y;
						this.d2 = this.circles[this.i].radius + this.C.radius + 4;
						if (this.cmode == 5)
						{
							this.d2 = this.d2 - 4;
						}
						if (this.dx * this.dx + this.dy * this.dy <= this.d2 * this.d2)
						{
							if (this.cmode == 5)
							{
								this.G.lineStyle(2, 16777215, 0.5);
								this.G.moveTo(this.C.center.x, this.C.center.y);
								this.G.lineTo(this.circles[this.i].center.x, this.circles[this.i].center.y);
							}
							this.i = this.circles.length;
							this.bd.draw(this.S);
							this.MODE = 0;
						}
						var _loc_2:String = this;
						var _loc_3:* = this.i + 1;
						_loc_2.i = _loc_3;
					}
					if (this.C.center.x <= this.C.radius || this.C.center.x >= 1100 - this.C.radius || this.C.center.y <= this.C.radius || this.C.center.y >= 800 - this.C.radius)
					{
						this.bd.draw(this.S);
						this.MODE = 0;
					}
				}
				var _loc_2:String = this;
				var _loc_3:* = this.j + 1;
				_loc_2.j = _loc_3;
			}
			return;
		}// end function
		
		public function mh(event:MouseEvent) : void
		{
			if (this.t > 6000)
			{
				stage.addEventListener(Event.ENTER_FRAME, this.handler);
			}
			this.t = 0;
			this.t2 = 0;
			this.ok = 0;
			if (this.cmode == 0)
			{
				this.cmode = 1;
			}
			else if (this.cmode == 1)
			{
				this.cmode = 2;
			}
			else if (this.cmode == 2)
			{
				this.cmode = 3;
			}
			else if (this.cmode == 3)
			{
				this.cmode = 4;
			}
			else if (this.cmode == 4)
			{
				this.cmode = 5;
			}
			else if (this.cmode == 5)
			{
				this.cmode = 0;
			}
			if (this.cmode == 0 || this.cmode == 2 || this.cmode == 3 || this.cmode == 4 || this.cmode == 5)
			{
				this.bd.fillRect(this.bd.rect, 0);
			}
			if (this.cmode == 1)
			{
				this.bd.fillRect(this.bd.rect, 16777215);
			}
			this.circles = new Vector.<Circle>;
			this.MODE = 0;
			return;
		}// end function
		
		public function getC(param1:int) : uint
		{
			if (param1 == 0)
			{
				return 16777215;
			}
			if (param1 == 1)
			{
				return 4473924;
			}
			if (param1 == 2)
			{
				return Math.random() * 16777215;
			}
			if (param1 == 5)
			{
				return 4473924;
			}
			return 0;
		}// end function
		
		function __setProp_BUTTON_Scene1_Layer1_0()
		{
			try
			{
				this.BUTTON["componentInspectorSetting"] = true;
			}
			catch (e:Error)
			{
			}
			this.BUTTON.emphasized = false;
			this.BUTTON.enabled = true;
			this.BUTTON.label = "Change Mode";
			this.BUTTON.labelPlacement = "right";
			this.BUTTON.selected = false;
			this.BUTTON.toggle = false;
			this.BUTTON.visible = true;
			try
			{
				this.BUTTON["componentInspectorSetting"] = false;
			}
			catch (e:Error)
			{
			}
			return;
		}// end function
		
		function frame1()
		{
			this.circles = new Vector.<Circle>;
			stage.addEventListener(Event.ENTER_FRAME, this.handler);
			this.MODE = 0;
			this.ok = 0;
			this.bd = new BitmapData(1100, 800, false, 0);
			this.b = new Bitmap(this.bd);
			addChild(this.b);
			this.b.width = 550;
			this.b.height = 400;
			this.S = new Sprite();
			this.S.scaleX = 0.5;
			this.S.scaleY = 0.5;
			this.G = this.S.graphics;
			this.G.lineStyle(0.1, Math.random() * 16777215);
			addChild(this.S);
			this.t = 0;
			this.t2 = 0;
			addChild(this.BUTTON);
			this.BUTTON.addEventListener(MouseEvent.MOUSE_DOWN, this.mh);
			this.cmode = 0;
			return;
		}// end function
		
	}
}                          