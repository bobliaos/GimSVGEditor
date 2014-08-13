package com
{
	import flash.geom.Point;

	public class SVGParser
	{
		private static var svgXML:XML;
		
		private static const PATH_MODE_XML_STRING:String = "<path nodeId='' nodeTypeId='' bindNodeIds='' nodePosition='' bindShopId='' fill='' deep='' d=''/>";
		private static const DEFAULT_NODE_TYPE_ID:String = "-1";
		private static const DEFAULT_FILL:String = "#FFFFFF";
		private static const DEFAULT_DEEP:String = "30";
		private static const DEFAULT_D:String = "";
		
		public function SVGParser()
		{
		}
		
		public static function coverToAllPath(SVGString:String):XML
		{
			svgXML = getClearedXML(SVGString);
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
			
			var bindShopId:String = "";
			if(xml.@bindShopId.toString() == "" && xml.@id.toString() != "")
			{
				bindShopId = xml.@id.split("_x")[1];
				bindShopId = bindShopId.replace("_","");
				bindShopId = bindShopId.substring(1,bindShopId.length);
			}
			else if(xml.@bindShopId.toString() != "")
			{
				bindShopId = xml.@bindShopId.toString();
			}
			
			simpleXML.@nodeId = xml.@nodeId.toString() != "" ? xml.@nodeId : generateNodeId();
			simpleXML.@nodeTypeId = xml.@nodeTypeId.toString() != "" ? xml.@nodeTypeId : DEFAULT_NODE_TYPE_ID;
			simpleXML.@bindNodeIds = xml.@bindNodeIds.toString() != "" ? xml.@bindNodeIds : "";
			simpleXML.@bindShopId = bindShopId;
			simpleXML.@fill = xml.@fill.toString() != "" ? xml.@fill : DEFAULT_FILL;
			simpleXML.@deep = xml.@deep.toString() != "" ? xml.@deep : DEFAULT_DEEP;
			simpleXML.@d = xml.@d.toString() != "" ? xml.@d : DEFAULT_D;
			simpleXML.@nodePosition = xml.@nodePosition.toString() != "" ? xml.@nodePosition : calculateNodePosition(simpleXML.@d);
			return simpleXML;
		}
		
		private static function calculateNodePosition(svgPathData:String):String
		{
			const DEGS_TO_RADS:int = Math.PI / 180, UNIT_SIZE:int = 100;
			const DIGIT_0:int = 48, DIGIT_9:int = 57, COMMA:int = 44, SPACE:int = 32, PERIOD:int = 46, MINUS:int = 45;
			
			var idx:int = 1, len:int = svgPathData.length, activeCmd:String,
				x:Number = 0, y:Number = 0, nx:Number = 0, ny:Number = 0, firstX:Number = NaN, firstY:Number = NaN,
				x1:Number = 0, x2:Number = 0, y1:Number = 0, y2:Number = 0,
				rx:Number = 0, ry:Number = 0, xar:Number = 0, laf:Number = 0, sf:Number = 0, cx:Number, cy:Number;
			var points:Array = [];
			
			function eatNum():Number {
				var sidx:int, c:Number, isFloat:Boolean = false, s:String;
				
				while (idx < len) {
					c = svgPathData.charCodeAt(idx);
					if (c !== COMMA && c !== SPACE) break;
					idx++;
				}
				if (c === MINUS)
					sidx = idx++;
				else
					sidx = idx;
				
				while (idx < len) {
					c = svgPathData.charCodeAt(idx);
					if (DIGIT_0 <= c && c <= DIGIT_9)    //0~9
					{
						idx++;
						continue;
					}
					else if (c === PERIOD)               //.
					{
						idx++;
						isFloat = true;
						continue;
					}
					
					s = svgPathData.substring(sidx, idx);
					break;
				}
				return isFloat ? parseFloat(s) : parseInt(s);
			}
			
			function nextIsNum():Boolean {
				var c:int;
				while (idx < len) {
					c = svgPathData.charCodeAt(idx);
					if (c !== COMMA && c !== SPACE) break;
					idx++;
				}
				
				c = svgPathData.charCodeAt(idx);
				return (c === MINUS || (DIGIT_0 <= c && c <= DIGIT_9));
			}
			
			var canRepeat:Boolean;
			activeCmd = svgPathData.charAt(0);
			while (idx <= len) {
				canRepeat = true;
				switch (activeCmd) {
					case 'M':
						x = eatNum();
						y = eatNum();
						points.push(new Point(x, y));
						activeCmd = 'L';
						firstX = x;
						firstY = y;
						break;
					case 'm':
						x += eatNum();
						y += eatNum();
						points.push(new Point(x, y));
						activeCmd = 'L';
						firstX = x;
						firstY = y;
						break;
					case 'Z':
						break;
					case 'z':
						canRepeat = false;
						if (x !== firstX || y !== firstY)
							points.push(new Point(firstX, firstY));
						break;
					case 'L':
					case 'H':
					case 'V':
						nx = (activeCmd === 'V') ? x : eatNum();
						ny = (activeCmd === 'H') ? y : eatNum();
						points.push(new Point(nx, ny));
						x = nx;
						y = ny;
						break;
					case 'l':
					case 'h':
					case 'v':
						nx = (activeCmd === 'v') ? x : (x + eatNum());
						ny = (activeCmd === 'h') ? y : (y + eatNum());
						points.push(new Point(nx, ny));
						x = nx;
						y = ny;
						break;
					case 'C':
						x1 = eatNum();
						y1 = eatNum();
					case 'S':
						if (activeCmd === 'S') {
							x1 = 2 * x - x2;
							y1 = 2 * y - y2;
						}
						x2 = eatNum();
						y2 = eatNum();
						nx = eatNum();
						ny = eatNum();
						points.push(new Point(x1, y1));
						points.push(new Point(x2, y2));
						points.push(new Point(nx, ny));
						x = nx;
						y = ny;
						break;
					case 'c':
						x1 = x + eatNum();
						y1 = y + eatNum();
					case 's':
						if (activeCmd === 's') {
							x1 = 2 * x - x2;
							y1 = 2 * y - y2;
						}
						x2 = x + eatNum();
						y2 = y + eatNum();
						nx = x + eatNum();
						ny = y + eatNum();
						points.push(new Point(x1, y1));
						points.push(new Point(x2, y2));
						points.push(new Point(nx, ny));
						x = nx;
						y = ny;
						break;
					case 'Q':
						x1 = eatNum();
						y1 = eatNum();
					case 'T':
						if (activeCmd === 'T') {
							x1 = 2 * x - x1;
							y1 = 2 * y - y1;
						}
						nx = eatNum();
						ny = eatNum();
						points.push(new Point(x1, y1));
						points.push(new Point(nx, ny));
						x = nx;
						y = ny;
						break;
					case 'q':
						x1 = x + eatNum();
						y1 = y + eatNum();
					case 't':
						if (activeCmd === 't') {
							x1 = 2 * x - x1;
							y1 = 2 * y - y1;
						}
						nx = x + eatNum();
						ny = y + eatNum();
						points.push(new Point(x1, y1));
						points.push(new Point(nx, ny));
						x = nx;
						y = ny;
						break;
					case 'A':
						rx = eatNum();
						ry = eatNum();
						xar = eatNum() * DEGS_TO_RADS;
						laf = eatNum();
						sf = eatNum();
						nx = eatNum();
						ny = eatNum();
						x1 = Math.cos(xar) * (x - nx) / 2 + Math.sin(xar) * (y - ny) / 2;
						y1 = -Math.sin(xar) * (x - nx) / 2 + Math.cos(xar) * (y - ny) / 2;
						
						var norm:Number = Math.sqrt(
							(rx * rx * ry * ry - rx * rx * y1 * y1 - ry * ry * x1 * x1) /
							(rx * rx * y1 * y1 + ry * ry * x1 * x1));
						if (laf === sf) norm = -norm;
						x2 = norm * rx * y1 / ry;
						y2 = norm * -ry * x1 / rx;
						
						cx = Math.cos(xar) * x2 - Math.sin(xar) * y2 + (x + nx) / 2;
						cy = Math.sin(xar) * x2 - Math.cos(xar) * y2 + (y + ny) / 2;
						
						points.push(new Point(cx, cy));
						x = nx;
						y = ny;
						break;
					default :
						//                    throw  new Error("weird path command:" + activeCmd);
						break;
				}
				
				if (canRepeat && nextIsNum())
					continue;
				activeCmd = svgPathData.charAt(idx++);
			}
			
			var minX:Number = Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE;
			var maxX:Number = Number.MIN_VALUE;
			var maxY:Number = Number.MIN_VALUE;
			for each(var point:Point in points)
			{
				if(point.x < minX) minX = point.x;
				if(point.y < minY) minY = point.y;
				if(point.x > maxX) maxX = point.x;
				if(point.y > maxY) maxY = point.y;
			}
			return ((maxX - minX) * 0.5 + minX).toFixed(2) + "," + ((maxY - minY) * 0.5 + minY).toFixed(2);
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
//			svgXML.normalize();
			return svgXML;
		}
		
		public static function generateNodeXML(localX:Number, localY:Number):XML
		{
			var xmlString:String = "<path nodeTypeId=\"0\" nodePosition=\"" + localX + "," + localY + "\" d=\"M" + localX + "," + localY + "Z\"/>";
			return formatSimpleXML(new XML(xmlString));
		}
	}
}