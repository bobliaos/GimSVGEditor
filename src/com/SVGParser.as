package com
{
	public class SVGParser
	{
		public function SVGParser()
		{
		}
		
		private static var svgXML:XML;
		
		public static function coverToAllPath(SVGString:String):XML
		{
			svgXML = getClearedXML(SVGString);
			var xml:XML = convertToPathXML(svgXML);
			return convertToPathXML(svgXML);
		}
		
		private static function convertToPathXML(origXML:XML):XML
		{
			for (var nodeIndex:String in origXML.children())
			{
				var xml:XML = origXML.children()[nodeIndex];
				if(xml.hasComplexContent())
					convertToPathXML(xml);
				else
					origXML.children()[nodeIndex] = formatSimpleXML(xml);
			}
			return origXML;
		}
		
		private static const PATH_MODE_XML_STRING:String = "<path nodeId='' placeTypeId='' bindNodeIds='' nodePosition='' fill='' deep='' d=''/>";
		private static const DEFAULT_PLACE_TYPE:String = "-1";
		private static const DEFAULT_NODE_POSITION:String = "0,0";
		private static const DEFAULT_FILL:String = "#FFFFFF";
		private static const DEFAULT_DEEP:String = "1";
		private static const DEFAULT_D:String = "1";
		
		private static function formatSimpleXML(xml:XML):XML
		{
			var simpleXML:XML = XML(PATH_MODE_XML_STRING);
			switch(xml.localName())
			{
				case "polygon":
					var polygonPointsArr:Array = xml.@points.split(" ");
					var polygonPointsString:String = "M";
					for each(var str:String in polygonPointsArr)
					{
						if(str.indexOf(",") > -1)
						{
							polygonPointsString += (polygonPointsString == "M" ? "" : " L") + str;
						}
					}
					polygonPointsString += "Z";
					xml.@d = polygonPointsString;
					break;
				case "rect":
					var origX:Number = xml.@x;
					var origY:Number = xml.@y;
					var origWidth:Number = xml.@width;
					var origHeight:Number = xml.@height;
					var rectPointsString:String = "M" + origX + "," + origY + " L" + (origX + origWidth) + "," + origY + " L" + (origX + origWidth) + "," + (origY + origHeight) + " L" + origX + "," + (origY + origHeight) + "Z";
					xml.@d = rectPointsString;
					break;
				default:
					break;
			}
			simpleXML.@nodeId = xml.@nodeId.toString() != "" ? xml.@nodeId : generateNodeId();
			simpleXML.@placeTypeId = xml.@placeTypeId.toString() != "" ? xml.@placeTypeId : DEFAULT_PLACE_TYPE;
			simpleXML.@bindNodeIds = xml.@bindNodeIds.toString() != "" ? xml.@bindNodeIds : "";
			simpleXML.@nodePosition = xml.@nodePosition.toString() != "" ? xml.@nodePosition : DEFAULT_NODE_POSITION;
			simpleXML.@fill = xml.@fill.toString() != "" ? xml.@fill : DEFAULT_FILL;
			simpleXML.@deep = xml.@deep.toString() != "" ? xml.@deep : DEFAULT_DEEP;
			simpleXML.@d = xml.@d.toString() != "" ? xml.@d : DEFAULT_D;
			return simpleXML;
		}
		
		private static function generateNodeId():String
		{
			var date:Date = new Date();
			return "node_" + date.fullYear + "_" + (date.month + 1) + "_" + date.date + "_" + date.toLocaleTimeString().split(" ")[0] + "_" + int(Math.random() * 10000);
		}
		
		private static function getClearedXML(SVGString:String):XML
		{
			SVGString = SVGString.replace(/\r/g,"");
			SVGString = SVGString.replace(/\n/g,"");
			SVGString = SVGString.replace(/\t/g,"");
			
			var svgXML:XML = XML(SVGString);
			svgXML.normalize();
			return svgXML;
		}
	}
}