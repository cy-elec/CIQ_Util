import Toybox.Lang;
import Toybox.Math;
import Toybox.Graphics;

module Util {
	module Graphs {
		
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
	}
}