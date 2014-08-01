package com
{
	public class SVGParser
	{
		public function SVGParser()
		{
		}
		
		public static function coverToAllPath(SVGString:String):String
		{
			SVGString = SVGString.replace(/\r/g,"");
			SVGString = SVGString.replace(/\n/g,"");
			SVGString = SVGString.replace(/\t/g,"");
			
			var svgXML:XML = XML(SVGString);
			var arr:Array = getAllPath(svgXML);
			var returnXML:XML = new XML("<svg/>");
			for(var i:int = 0;i < arr.length;i ++)
			{
				var xml:XML = changeToPath(arr[i]);
				if(xml)
					returnXML.appendChild(xml);
			}

			var returnString:String = returnXML.toString();
			return returnString;
		}
		
		private static function changeToPath(xml:XML):XML
		{
			var xmlString:String;
			switch(xml.localName())
			{
				case "polygon":
					var pointsString:String = xml.@points;
					var pointsArr:Array = pointsString.split(" ");
					pointsString = "M";
					for each(var str:String in pointsArr)
					{
						if(str.indexOf(",") > -1)
						{
							pointsString += (pointsString == "M" ? "" : " L") + str;
						}
					}
					pointsString += "Z";
					var fill:String = xml.@fill;
					xmlString = "<path fill=\"" + fill + "\" height=\"" + 10 + "\" d=\"" + pointsString + "\"/>"
					xml = XML(xmlString);
					break;
				case "path":
					xmlString = "<path fill=\"" + xml.@fill + "\" height=\"" + 10 + "\" d=\"" + xml.@d + "\"/>";
					xml = XML(xmlString);
					break;
				default:
					xml = null;
					break;
			}
			return xml;
		}
		
		private static function getAllPath(svgXML:XML):Array
		{
			var arr:Array = [];
			for each(var xml:XML in svgXML.children())
			{
				if(!xml.hasSimpleContent()) 
					arr = arr.concat(getAllPath(xml));
				else
					arr.push(xml);
			}
			return arr;
		}
	}
}