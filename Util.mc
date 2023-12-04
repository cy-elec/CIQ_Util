import Toybox.Lang;
import Toybox.Math;
import Toybox.Graphics;

module Util {

	module Maths {
		function uniformRand(low as Number, high as Number) as Number {
			var range = high-low+1;
			var limit = 0x7FFFFFFF - 0x7FFFFFFF%range;
			var r = 0;
			do {
				r = Math.rand();
			} while (r >= limit);
			return low + r % range;
		}

		function distanceOnLine(slope as Lang.Numeric, distance as Lang.Numeric, x as Lang.Number, y as Lang.Number, yIntercept as Lang.Numeric) as Lang.Array<Lang.Numeric>{
			var slopesqr = Math.pow(slope, 2);
			var r = Math.pow(distance, 2);
			var eq1 = (-Math.pow(yIntercept, 2)-2*yIntercept*slope*x+2*yIntercept*y-slopesqr*Math.pow(x, 2)+(r==0?1:r)*slopesqr+2*slope*x*y-Math.pow(y, 2)+r);
			var eq2 = (Math.pow(slope, 4)+2*slopesqr+1);
			var eq3 = (-yIntercept*slope+slope*y+x);
			var eq4 = (slopesqr+1);
			var eq5 = Math.sqrt(eq1/eq2);
			var eq6 = eq3/eq4;
			return [eq5+eq6, -eq5+eq6];
		}
	}

	module Arrays {
		function max(array as Lang.Array<Lang.Numeric>) as Lang.Numeric {
			var array_max = 0;
			for (var i=0; i<array.size(); i++) {
				if (array[i] > array_max) {
					array_max = array[i];
				}
			}
			return array_max;
		}
		function extremum(array as Lang.Array<Lang.Numeric>) as Lang.Numeric {
			var array_max = 0;
			for (var i=0; i<array.size(); i++) {
				if (array_max < 0) {
					if (array[i] < array_max || array[i] > -array_max) {
						array_max = array[i];
					}
				}
				else if (array_max >= 0) {
					if (array[i] < -array_max || array[i] > array_max) {
						array_max = array[i];
					}
				}
			}
			return array_max;
		}
		function abs(array as Lang.Array<Lang.Numeric>) as Lang.Array<Lang.Numeric> {
			var ret_array = new [array.size()];
			for (var i=0; i<array.size(); i++) {
				ret_array[i] = array[i].abs();
			}
			return ret_array;
		}
	}

	module Graphs {
		enum Quadrants {
			QUADRANT_1 = 1,
			QUADRANT_2 = 2,
			QUADRANT_3 = 4,
			QUADRANT_4 = 8,
		}
		typedef QuadrantType as Lang.Number or $.Util.Graphs.Quadrants;

		class Graph {
			
			protected var _x as Lang.Number or Null;
			protected var _y as Lang.Number or Null;
			protected var _width as Lang.Number or Null;
			protected var _height as Lang.Number or Null;
			protected var _quadrants as $.Util.Graphs.QuadrantType;
			protected var _gridUnits as Lang.Number;
			protected var _dataWidth as Lang.Number or Null;
			protected var _dataSpacing as Lang.Number;

			protected var _labelsFont as Graphics.FontType;

			protected var _foregroundColor as Graphics.ColorType;
			protected var _gridColor as Graphics.ColorType;
			protected var _backgroundColor as Graphics.ColorType;
			protected var _labelsColor as Graphics.ColorType;
			protected var _unitsColor as Graphics.ColorType;

			function initialize(options as {:x as Lang.Number, :y as Lang.Number, :width as Lang.Number, :height as Lang.Number, :quadrants as $.Util.Graphs.QuadrantType, :gridUnits as Lang.Number, :dataWidth as Lang.Number, :dataSpacing as Lang.Number, :labelsFont as Graphics.FontType, :foregroundColor as Graphics.ColorType, :gridColor as Graphics.ColorType, :backgroundColor as Graphics.ColorType, :labelsColor as Graphics.ColorType, :unitsColor as Graphics.ColorType}) {
				_x = options[:x];
				_y = options[:y];
				_width = options[:width];
				_height = options[:height];
				_quadrants = options[:quadrants] != null ? options[:quadrants] : $.Util.Graphs.QUADRANT_1;	
				_gridUnits = options[:gridUnits] != null ? options[:gridUnits] : 50;
				_dataWidth = null;
				_dataSpacing = options[:dataSpacing] != null ? options[:dataSpacing] : 0;

				_labelsFont = options[:labelsFont] != null ? options[:labelsFont] : Graphics.FONT_XTINY;
				
				_foregroundColor = options[:foregroundColor] != null ? options[:foregroundColor] : Graphics.COLOR_WHITE;
				_gridColor = options[:gridColor] != null ? options[:gridColor] : Graphics.COLOR_LT_GRAY;
				_backgroundColor = options[:backgroundColor] != null ? options[:backgroundColor] : Graphics.COLOR_TRANSPARENT;
				_labelsColor = options[:labelsColor] != null ? options[:labelsColor] : Graphics.COLOR_BLUE;
				_unitsColor = options[:unitsColor] != null ? options[:unitsColor] : Graphics.COLOR_DK_GRAY;
			}

			function drawOutline(dc as Dc, data as Lang.Array<Lang.Number>, drawHorizontalGrid as Lang.Boolean, drawGraph as Lang.Boolean) {
				var x = _x != null ? _x : dc.getWidth()/4;
				var y = _y != null ? _y : dc.getHeight()-dc.getHeight()/4;
				var width = _width != null ? _width : dc.getWidth()/2;
				var height = _height != null ? _height : dc.getHeight()/2; 

				
				var maxValue = $.Util.Arrays.extremum(data).abs();
				var scaling = 1d*height/(maxValue>0?maxValue:1);

				// draw grid
				if (drawHorizontalGrid) {
					for (var i=0, u=0; i<height; i+=scaling*_gridUnits, u+=_gridUnits) {
						dc.setColor(_gridColor, _backgroundColor);
						if (_quadrants & $.Util.Graphs.QUADRANT_1) {
							dc.drawLine(x, y-i, x+width, y-i);
						}
						if (_quadrants & $.Util.Graphs.QUADRANT_4) {
							dc.drawLine(x, y+i, x+width, y+i);
						}
					}
				}
				
				if (drawGraph) {
					// draw quadrants
					dc.setColor(_foregroundColor, _backgroundColor);
					dc.drawLine(x-5, y, x+width, y);
					if (_quadrants & $.Util.Graphs.QUADRANT_1) {
						dc.drawLine(x, y, x, y-height);
					}
					if (_quadrants & $.Util.Graphs.QUADRANT_4) {
						dc.drawLine(x, y, x, y+height);
					}
				}

			}
			function drawLabels(dc as Dc, data as Lang.Array<Lang.Number>, labels as Lang.Array<Lang.String>, drawUnits as Lang.Boolean, drawLabels as Lang.Boolean) {
				var x = _x != null ? _x : dc.getWidth()/4;
				var y = _y != null ? _y : dc.getHeight()-dc.getHeight()/4;
				var width = _width != null ? _width : dc.getWidth()/2;
				var height = _height != null ? _height : dc.getHeight()/2; 

				
				var maxValue = $.Util.Arrays.extremum(data).abs();
				var scaling = 1d*height/(maxValue>0?maxValue:1);
				
				var dataWidth = _dataWidth;
				if (dataWidth == null) {
					dataWidth = width/data.size();
					if (dataWidth < 1) {
						dataWidth = 1;
					}
				}

				// draw units
				if (drawUnits) {
					for (var i=0, u=0; i<height; i+=scaling*_gridUnits, u+=_gridUnits) {
						if (u!=0) {
							dc.setColor(_unitsColor, _backgroundColor);
							if (_quadrants & $.Util.Graphs.QUADRANT_1) {
								dc.drawText(x-5, y-i, _labelsFont, ""+u, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
							}
							if (_quadrants & $.Util.Graphs.QUADRANT_4) {
								dc.drawText(x-5, y+i, _labelsFont, "-"+u, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
							}
						}
					}
				}

				if (drawLabels) {
					for (var i=0; i<data.size(); i++) {
						dc.setColor(_labelsColor, _backgroundColor);
						dc.drawText(x+_dataSpacing+(dataWidth)*i+(dataWidth-_dataSpacing)/2, y, _labelsFont, i<labels.size()?labels[i]:i, Graphics.TEXT_JUSTIFY_CENTER);
					}
				}
			}

			function setLocation(x as Lang.Number or Null, y as Lang.Number or Null) {
				_x = x;
				_y = y;
			}
			function getLocation() {
				return [_x, _y];
			}

			function setSize(width as Lang.Number or Null, height as Lang.Number or Null) {
				_width = width;
				_height = height;
			}
			function getSize() {
				return [_width, _height];
			}

			function setQuadrants(quadrants as $.Util.Graphs.QuadrantType) {
				_quadrants = quadrants;
			}
			function getQuadrants() {
				return _quadrants;
			}

			function setGridUnits(gridUnits as Lang.Number) {
				_gridUnits = gridUnits;
			}
			function getGridUnits() {
				return _gridUnits;
			}

			function setFormatting(dataWidth as Lang.Number or Null, dataSpacing as Lang.Number) {
				_dataWidth = dataWidth;
				_dataSpacing = dataSpacing;
			}
			function getFormatting() {
				return [_dataWidth, _dataSpacing];
			}

			function setFont(labelsFont as Graphics.FontType) {
				_labelsFont = labelsFont;
			}
			function getFont() {
				return _labelsFont;
			}

			function setColors(foregroundColor as Graphics.ColorType, backgroundColor as Graphics.ColorType, gridColor as Graphics.ColorType, labelColor as Graphics.ColorType, unitsColor as Graphics.ColorType) {
				_foregroundColor = foregroundColor;
				_backgroundColor = backgroundColor;
				_gridColor = gridColor;
				_labelsColor = labelColor;
				_unitsColor = unitsColor;
			}
			function getColors() {
				return {:foregroundColor => _foregroundColor, :backgroundColor => _backgroundColor, :gridColor => _gridColor, :labelsColor => _labelsColor, :unitsColor => _unitsColor};
			}
		}
		
		class BarGraph extends $.Util.Graphs.Graph {
			var _barPositiveColor as Graphics.ColorType;
			var _barNegativeColor as Graphics.ColorType;

			function initialize(options as {:x as Lang.Number, :y as Lang.Number, :width as Lang.Number, :height as Lang.Number, :quadrants as $.Util.Graphs.QuadrantType, :gridUnits as Lang.Number, :dataWidth as Lang.Number, :dataSpacing as Lang.Number, :labelsFont as Graphics.FontType, :foregroundColor as Graphics.ColorType, :gridColor as Graphics.ColorType, :backgroundColor as Graphics.ColorType, :labelsColor as Graphics.ColorType, :unitsColor as Graphics.ColorType, :barPositiveColor as Graphics.ColorType, :barNegativeColor as Graphics.ColorType}) {
				Graph.initialize(options);
				_barPositiveColor = options[:barPositiveColor] != null ? options[:barPositiveColor] : _foregroundColor;
				_barNegativeColor = options[:barNegativeColor] != null ? options[:barNegativeColor] : _foregroundColor;
			}

			function drawGraph(dc as Dc, data as Lang.Array<Lang.Number>) {
				var x = _x != null ? _x : dc.getWidth()/4;
				var y = _y != null ? _y : dc.getHeight()-dc.getHeight()/4;
				var width = _width != null ? _width : dc.getWidth()/2;
				var height = _height != null ? _height : dc.getHeight()/2; 
				
				var maxValue = $.Util.Arrays.extremum(data).abs();
				var scaling = 1d*height/(maxValue>0?maxValue:1);

				var dataWidth = _dataWidth;
				if (dataWidth == null) {
					dataWidth = width/data.size();
					if (dataWidth < 1) {
						dataWidth = 1;
					}
				}

				for (var i=0; i<data.size(); i++) {
					var cHeight = Math.ceil(scaling*data[i]);
						
					if (data[i]>0) {
						dc.setColor(_barPositiveColor, _backgroundColor);
						dc.fillRectangle(x+_dataSpacing+(dataWidth)*i, y-cHeight, dataWidth-_dataSpacing, cHeight);
					}
					else {
						dc.setColor(_barNegativeColor, _backgroundColor);
						dc.fillRectangle(x+_dataSpacing+(dataWidth)*i, y, dataWidth-_dataSpacing, -cHeight);
					}
				}
			}

			function draw(dc as Dc, data as Lang.Array<Lang.Number>, options as {:labels as Lang.Array<Lang.String>, :labelsDc as Dc, :drawHorizontalGrid as Lang.Boolean, :drawGraph as Lang.Boolean, :drawLabels as Lang.Boolean, :drawUnits as Lang.Boolean}) {
				var width = _width != null ? _width : dc.getWidth()/2; 

				var drawHorizontalGrid = options[:drawHorizontalGrid] != null ? options[:drawHorizontalGrid] : false;
				var drawGraph = options[:drawGraph] != null ? options[:drawGraph] : true;
				var drawLabels = options[:drawLabels] != null ? options[:drawLabels] : false;
				var drawUnits = options[:drawUnits] != null ? options[:drawUnits] : false;

				var labels =  options[:labels] != null ? options[:labels] : new [0];
				var labelsDc = options[:labelsDc] != null ? options[:labelsDc] : null;

				var dataWidth = _dataWidth;
				if (dataWidth == null) {
					dataWidth = width/data.size();
					if (dataWidth < 1) {
						dataWidth = 1;
					}
				}

				$.Util.Graphs.Graph.drawOutline(dc, data, drawHorizontalGrid, drawGraph);
				if (drawGraph) {
					me.drawGraph(dc, data);
				}
				if (labelsDc != null) {
					$.Util.Graphs.Graph.drawLabels(labelsDc, data, labels, drawUnits, drawLabels);
				}
			}

			function setBarColors(barPositiveColor as Graphics.ColorType, barNegativeColor as Graphics.ColorType) {
				_barPositiveColor = barPositiveColor;
				_barNegativeColor = barNegativeColor;
			}
			function getColors() {
				var colors =  $.Util.Graphs.Graph.getColors();
				colors.put(:barPositiveColor, _barPositiveColor);
				colors.put(:barNegativeColor, _barNegativeColor);
				return colors;
			}
		}

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