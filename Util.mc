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

			function setSize(width as Lang.Number or Null, height as Lang.Number or Null) {
				_width = width;
				_height = height;
			}

			function setQuadrants(quadrants as $.Util.Graphs.QuadrantType) {
				_quadrants = quadrants;
			}

			function setGridUnits(gridUnits as Lang.Number) {
				_gridUnits = gridUnits;
			}
			
			function setFormatting(dataWidth as Lang.Number or Null, dataSpacing as Lang.Number) {
				_dataWidth = dataWidth;
				_dataSpacing = dataSpacing;
			}

			function setFont(labelsFont as Graphics.FontType) {
				_labelsFont = labelsFont;
			}

			function setColors(foregroundColor as Graphics.ColorType, backgroundColor as Graphics.ColorType, gridColor as Graphics.ColorType, labelColor as Graphics.ColorType, unitsColor as Graphics.ColorType) {
				_foregroundColor = foregroundColor;
				_backgroundColor = backgroundColor;
				_gridColor = gridColor;
				_labelsColor = labelColor;
				_unitsColor = unitsColor;
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
		}
	}
}