package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class Node extends Sprite
	{
		public function Node()
		{
			var radius:Number = 5;
			this.graphics.beginFill(0,0.1);
			this.graphics.drawCircle(0,2,radius + 2);
			this.graphics.beginFill(0xFFFFFF,1);
			this.graphics.drawCircle(0,0,radius + 2);
			this.graphics.beginFill(0x0099CC,1);
			this.graphics.drawCircle(0,0,radius);
			this.graphics.endFill();
			
			this.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void{
				e.stopPropagation();
			});
		}
	}
}