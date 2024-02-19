import Toybox.Lang;
import Toybox.Math;
import Toybox.Graphics;

module Util {
	module Graphs {

		class LineGraph extends $.Util.Graphs.Graph {
			var _radius as Lang.Number;
			var _slopePositiveColor as Graphics.ColorType;
			var _slopeNegativeColor as Graphics.ColorType;
			var _pointColor as Graphics.ColorType;
			var _lineThickness as Lang.Number;
			var _lineSpacing as Lang.Number;

			function initialize(options as {:x as Lang.Number, :y as Lang.Number, :width as Lang.Number, :height as Lang.Number, :quadrants as $.Util.Graphs.QuadrantType, :gridUnits as Lang.Number, :dataWidth as Lang.Number, :dataSpacing as Lang.Number, :radius as Lang.Number, :lineThickness as Lang.Number, :lineSpacing as Lang.Number, :labelsFont as Graphics.FontType, :foregroundColor as Graphics.ColorType, :gridColor as Graphics.ColorType, :backgroundColor as Graphics.ColorType, :labelsColor as Graphics.ColorType, :unitsColor as Graphics.ColorType, :slopePositiveColor as Graphics.ColorType, :slopeNegativeColor as Graphics.ColorType, :pointColor as Graphics.ColorType}) {
				Graph.initialize(options);
				_slopePositiveColor = options[:slopePositiveColor] != null ? options[:slopePositiveColor] : _foregroundColor;
				_slopeNegativeColor = options[:slopeNegativeColor] != null ? options[:slopeNegativeColor] : _foregroundColor;
				_pointColor = options[:pointColor] != null ? options[:pointColor] : _foregroundColor;
				_radius = options[:radius] != null ? options[:radius] : 4;
				_lineThickness = options[:lineThickness] != null ? options[:lineThickness] : 2;
				_lineSpacing = options[:lineSpacing] != null ? options[:lineSpacing] : _radius*3/2;
				_dataSpacing = _dataSpacing==0?_radius:_dataSpacing;
			}

			function drawGraph(dc as Dc, data as Lang.Array<Lang.Number>, drawLines as Lang.Boolean) {
				var x = _x != null ? _x : dc.getWidth()/4;
				var y = _y != null ? _y : dc.getHeight()-dc.getHeight()/4;
				var width = _width != null ? _width : dc.getWidth()/2;
				var height = _height != null ? _height : dc.getHeight()/2; 
				
				var maxValue = $.Util.Arrays.extremum(data).abs();
				var scaling = 1d*height/(maxValue>0?maxValue:1);

				var dataWidth = _dataWidth;
				if (dataWidth == null) {
					dataWidth = width/data.size();
					if (dataWidth < _radius+_dataSpacing) {
						dataWidth = _radius+_dataSpacing;
					}
				}

				var lastDataCoord = new [0];
				for (var i=0; i<data.size(); i++) {
					var cHeight = Math.ceil(scaling*data[i]);
					
					if (lastDataCoord.size() > 0 ? drawLines : false) {	// cannot use Null check for lastDataCoord here due to "Attempting to perform container access on null" error - compiler fault
						var tmpx = (x+_dataSpacing+(dataWidth)*i) + (dataWidth-_dataSpacing)/2;
						var tmpy = cHeight;
						var startCorrectionFactor = (dataWidth-_dataSpacing)/2 + 1; // correct incorrect circle offset
						var slope = (tmpy-lastDataCoord[1])/(tmpx-lastDataCoord[0]-startCorrectionFactor);

						var drawX1 = lastDataCoord[0] + startCorrectionFactor + _lineSpacing;
						var drawY1 = y - lastDataCoord[1]; 
						var drawX2 = tmpx - _lineSpacing;
						var drawY2 = y - tmpy; 

						if (slope != 0) {
							var c = tmpy-slope*tmpx;
							var solutions1 = $.Util.Maths.distanceOnLine(slope, _lineSpacing, lastDataCoord[0]+startCorrectionFactor, lastDataCoord[1], c);
							var solutions2 = $.Util.Maths.distanceOnLine(slope, _lineSpacing, tmpx, tmpy, c);
							drawX1 = solutions1[0];
							drawY1 = y - (slope*drawX1+c) + (slope<0?1:-1);
							drawX2 = solutions2[1];
							drawY2 = y - (slope*drawX2+c);
						}

						if (data[i]>lastDataCoord[1]) {
							dc.setColor(_slopePositiveColor, _backgroundColor);
						}
						else if (data[i]<lastDataCoord[1]){
							dc.setColor(_slopeNegativeColor, _backgroundColor);
						}
						else {
							dc.setColor(_foregroundColor, _backgroundColor);
						}

						if (drawX1<drawX2) {
							dc.setPenWidth(_lineThickness);
							dc.drawLine(Math.round(drawX1), Math.round(drawY1), Math.round(drawX2), Math.round(drawY2));
							dc.setPenWidth(1);
						}
					}
					lastDataCoord = [x+_dataSpacing+(dataWidth)*i, cHeight];

					dc.setColor(_pointColor, _backgroundColor);
					dc.fillCircle(x+_dataSpacing+(dataWidth)*i+(dataWidth-_dataSpacing)/2, y-cHeight, _radius);
					
				}
			}

			function draw(dc as Dc, data as Lang.Array<Lang.Number>, options as {:labels as Lang.Array<Lang.String>, :labelsDc as Dc, :drawHorizontalGrid as Lang.Boolean, :drawGraph as Lang.Boolean, :drawLabels as Lang.Boolean, :drawUnits as Lang.Boolean, :drawLines as Lang.Boolean}) {
				var width = _width != null ? _width : dc.getWidth()/2; 

				var drawHorizontalGrid = options[:drawHorizontalGrid] != null ? options[:drawHorizontalGrid] : false;
				var drawGraph = options[:drawGraph] != null ? options[:drawGraph] : true;
				var drawLabels = options[:drawLabels] != null ? options[:drawLabels] : false;
				var drawUnits = options[:drawUnits] != null ? options[:drawUnits] : false;
				var drawLines = options[:drawLines] != null ? options[:drawLines] : true;

				var labels =  options[:labels] != null ? options[:labels] : new [0];
				var labelsDc = options[:labelsDc] != null ? options[:labelsDc] : null;

				var resetDW = false;

				if (_dataWidth == null) {
					resetDW = true;
					_dataWidth = width/data.size();
					if (_dataWidth < _radius+_dataSpacing) {
						_dataWidth = _radius+_dataSpacing;
					}
				}

				$.Util.Graphs.Graph.drawOutline(dc, data, drawHorizontalGrid, drawGraph);
				if (drawGraph) {
					me.drawGraph(dc, data, drawLines);
				}
				if (labelsDc != null) {
					$.Util.Graphs.Graph.drawLabels(labelsDc, data, labels, drawUnits, drawLabels);
				}

				if (resetDW) {
					_dataWidth = null;
				}
			}

			function drawLabels(dc as Dc, data as Lang.Array<Lang.Number>, labels as Lang.Array<Lang.String>, drawUnits as Lang.Boolean, drawLabels as Lang.Boolean) {
				var width = _width != null ? _width : dc.getWidth()/2; 

				var resetDW = false;

				if (_dataWidth == null) {
					resetDW = true;
					_dataWidth = width/data.size();
					if (_dataWidth < _radius+_dataSpacing) {
						_dataWidth = _radius+_dataSpacing;
					}
				}
				$.Util.Graphs.Graph.drawLabels(dc, data, labels, drawUnits, drawLabels);

				if (resetDW) {
					_dataWidth = null;
				}
			}

			function setRadius(radius as Lang.Number) {
				_radius = radius;
			}
			function getRadius() {
				return _radius;
			}

			function setSlopeColors(slopePositiveColor as Graphics.ColorType, slopeNegativeColor as Graphics.ColorType) {
				_slopePositiveColor = slopePositiveColor;
				_slopeNegativeColor = slopeNegativeColor;
			}
			function setPointColor(pointColor as Graphics.ColorType) {
				_pointColor = pointColor;
			}
			function getColors() {
				var colors =  $.Util.Graphs.Graph.getColors();
				colors.put(:slopePositiveColor, _slopePositiveColor);
				colors.put(:slopeNegativeColor, _slopeNegativeColor);
				colors.put(:pointColor, _pointColor);
				return colors;
			}
			function setLineProperties(lineThickness as Lang.Number, lineSpacing as Lang.Number) {
				_lineThickness = lineThickness;
				_lineSpacing = lineSpacing;
			}
			function getLineProperties() {
				return [_lineThickness, _lineSpacing];
			}
		}
	}
}