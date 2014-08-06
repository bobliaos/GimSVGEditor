package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class Node extends Sprite
	{
		public var sourceXML:XML;
		public var pathes:Array;
		
		public function Node(pathXML:XML)
		{
			this.sourceXML = pathXML;
			this.pathes = [];
			this.x = sourceXML.@nodePosition.split(',')[0];
			this.y = sourceXML.@nodePosition.split(',')[1];
			
			var radius:Number = 5;
			this.graphics.beginFill(0,0.1);
			this.graphics.drawCircle(0,2,radius + 2);
			this.graphics.beginFill(0xFFFFFF,1);
			this.graphics.drawCircle(0,0,radius + 2);
			this.graphics.beginFill(0x0099CC,1);
			this.graphics.drawCircle(0,0,radius);
			this.graphics.endFill();
		}
		
		public function addPath(path:NodePath):void
		{
			if(pathes.indexOf(path) < 0) pathes.push(path);
		}
	}
}