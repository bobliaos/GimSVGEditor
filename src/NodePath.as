package
{
	import flash.display.Sprite;
	
	public class NodePath extends Sprite
	{
		public function NodePath(startNode:Node,endNode:Node)
		{
			super();
			
			this.graphics.lineStyle(7,0xFFFFFF,1);
			this.graphics.moveTo(startNode.x,startNode.y);
			this.graphics.lineTo(endNode.x,endNode.y);			
			this.graphics.lineStyle(5,0xFF0033,1);
			this.graphics.moveTo(startNode.x,startNode.y);
			this.graphics.lineTo(endNode.x,endNode.y);
			this.graphics.endFill();
		}
	}
}