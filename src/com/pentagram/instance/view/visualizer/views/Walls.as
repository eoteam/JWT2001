package com.pentagram.instance.view.visualizer.views
{
	import org.cove.ape.APEGroup;
	import org.cove.ape.APEngine;
	import org.cove.ape.RectangleParticle;
	
	public class Walls extends APEGroup
	{
		public var t:RectangleParticle;
		public var b:RectangleParticle;
		public var l:RectangleParticle;
		public var r:RectangleParticle;
		
		public function Walls(engine:APEngine,bw:Number, bh:Number)
		{
			// top
			super(engine);
			t= new RectangleParticle(engine,bw/2, 0, bw, 10, 0, true,100);
			t.alwaysRepaint = true;
			addParticle(t);
			
			// this is the bottom
			b = new RectangleParticle(engine,bw/2, bh, bw, 100, 0, true,100);
			b.alwaysRepaint = true;
			addParticle(b);
			
			// left
			l = new RectangleParticle(engine,0, bh / 2, 10, bh, 0, true,100);
			l.alwaysRepaint = true;
			addParticle(l);  
			
			// right
			r = new RectangleParticle(engine,bw, bh / 2, 10, bh, 0, true,100);
			r.alwaysRepaint = true;
			addParticle(r);
			
			r.setFill(0xffffff,0);
			t.setFill(0xffffff,0);
			b.setFill(0xffffff,0);
			l.setFill(0xffffff,0);

		}
		public function update(bw:Number, bh:Number):void {
			t.px = bw/2; t.py = 0; t.width = bw; t.height = 10;
			
			//bw/2, bh, bw, 100, 0
			b.px = bw/2; b.py = bh-100; b.width = bw; b.height = 100;
			
			//(0, bh / 2, 10, bh
			l.px = 0; l.py = bh/2; l.width = 10; l.height = bh;
			
			//bw, bh / 2, 10, bh
			r.px = bw; r.py = bh/2; r.width = 10; r.height = bh;
		}
	}
}
