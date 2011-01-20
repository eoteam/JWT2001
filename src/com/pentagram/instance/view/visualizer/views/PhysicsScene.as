package com.pentagram.instance.view.visualizer.views
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.cove.ape.*;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;

	public class PhysicsScene extends SpriteVisualElement
	{
		public var balls:APEGroup;
		private var walls:Walls;
		
		private var timer:Timer;
		public function PhysicsScene()
		{
			APEngine.init(0);
			APEngine.container = this;
			APEngine.addForce(new VectorForce(false,0, 0));//Massless
			this.addEventListener(Event.ADDED_TO_STAGE,handleAddedStage);
			
			//timer.addEventListener(TimerEvent.TIMER,enterFrameHandler);
		}
		public function handleAddedStage(event:Event):void {
			walls = new Walls( stage.stageWidth, stage.stageHeight);
			balls = new APEGroup();
			APEngine.addGroup(balls);
			APEngine.addGroup(walls); 
			balls.addCollidable ( walls );
			//balls.collideInternal=true;
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);		
			
			//			timer = new Timer(10);
		}
		public function reset():void
		{
			balls.cleanup();
			APEngine.removeGroup(balls);
			for(var i:int = 0;i<this.numChildren;i++)			
			{
				this.removeChildAt(i);
			}			
			balls = new org.cove.ape.APEGroup();
			APEngine.addGroup(balls);
			balls.collideInternal=true;
		}
		public function start():void
		{
			//timer.start();
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		public function stop():void
		{
			//timer.stop();
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		private function enterFrameHandler(event:Event):void
		{
			APEngine.step();
			APEngine.paint();
			walls.update(stage.stageWidth, stage.stageHeight);
		}                 
	}
}