package com.pentagram.instance.view.visualizer
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.cove.ape.*;
	
	public class PhysicsScene extends Sprite
	{
		public var balls:Group;
		
		public function PhysicsScene()
		{
			APEngine.init(0	);
			APEngine.container = this;
			APEngine.addForce(new VectorForce(false,0, 0));//Massless
			balls = new Group();
			APEngine.addGroup(balls);
			balls.collideInternal=true;
			
		}
		public function reset():void
		{
			balls.cleanup();
			APEngine.removeGroup(balls);
			for(var i:int = 0;i<this.numChildren;i++)			
			{
				this.removeChildAt(i);
			}			
			balls = new Group();
			APEngine.addGroup(balls);
			balls.collideInternal=true;
		}
		public function start():void
		{
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		public function stop():void
		{
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		private function enterFrameHandler(event:Event):void
		{
			APEngine.step();
			APEngine.paint();
		}
	}
}