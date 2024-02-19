import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

module Util {
	
	module Menus {
		class RadioMenu extends WatchUi.Menu2 {
			var _lastSelectedItem as $.Util.Menus.RadioMenuItem or Null;
			var _onChangeCallback as Lang.Method or Null;

			public function initialize(options as { :title as Lang.String or Lang.Symbol or WatchUi.Drawable, :focus as Lang.Number, :icon as Graphics.BitmapType or WatchUi.Drawable or Lang.Symbol, :theme as WatchUi.MenuTheme or Null, :onChangeHandler as Lang.Method} or Null) {
				WatchUi.Menu2.initialize(options);
				_onChangeCallback = options[:onChangeHandler];
			}

			public function addItem(item as WatchUi.MenuItem) {
				item = (item as $.Util.Menus.RadioMenuItem);
				WatchUi.Menu2.addItem(item);
				item.setCallback(new Lang.Method(self, :onChange));
				if (_lastSelectedItem == null && item.isSelected()) {
					_lastSelectedItem = item;
				}
			}

			public function onChange(item as $.Util.Menus.RadioMenuItem) {
				if (_lastSelectedItem != item && item.isSelected()) {
					if (_lastSelectedItem != null) {
						_lastSelectedItem.setSelected(false);
					}
					_lastSelectedItem = item;
					if (_onChangeCallback != null) {
						_onChangeCallback.invoke(self);
					}
				}
			}

			public function onShow() {
				var item = _lastSelectedItem;
				var citem = WatchUi.Menu2.getItem(0) as $.Util.Menus.RadioMenuItem;
				for (var i=0; citem != null; i++, citem = WatchUi.Menu2.getItem(i)) {
					if (item == null && citem.isSelected()) {
						item = citem;
					}
					else if (citem != item){
						(citem.getIcon() as $.Util.Menus.RadioMenuDrawable).setSelected(false);
					}
				}
				if (_lastSelectedItem==null) {
					_lastSelectedItem = WatchUi.Menu2.getItem(0) as $.Util.Menus.RadioMenuItem;
					_lastSelectedItem.setSelected(true);
				}
				WatchUi.Menu2.setFocus(getSelectedIndex());
				WatchUi.Menu2.onShow();
			}

			public function setSelected(index as Lang.Number) {
				var item = WatchUi.Menu2.getItem(index);
				if (item != null) {
					(item as $.Util.Menus.RadioMenuItem).setSelected(true);
				}
			}

			public function getSelectedIndex() as Lang.Number {
				return _lastSelectedItem!=null?WatchUi.Menu2.findItemById(_lastSelectedItem.getId()):0;
			}
		}

		class RadioMenuItem extends WatchUi.IconMenuItem {
			
			var _changeCallback as Lang.Method or Null;

			public function initialize(label as Lang.String or Lang.Symbol, subLabel as Lang.String or Lang.Symbol or Null, identifier, selected as Lang.Boolean, options as { :alignment as MenuItem.Alignment} or Null) {
				WatchUi.IconMenuItem.initialize(label, subLabel, identifier, new $.Util.Menus.RadioMenuDrawable(selected), options);
			}

			public function setCallback(callback as Lang.Method) {
				_changeCallback = callback;
			}

			public function setSelected(_selected as Lang.Boolean) {
				(WatchUi.IconMenuItem.getIcon() as $.Util.Menus.RadioMenuDrawable).setSelected(_selected);
				if (_changeCallback != null) {
					_changeCallback.invoke(self);
				}
			}

			public function isSelected() as Lang.Boolean {
				return (WatchUi.IconMenuItem.getIcon() as $.Util.Menus.RadioMenuDrawable).isSelected();
			}

		}

		class RadioMenuDelegate extends WatchUi.Menu2InputDelegate {

			//! Constructor
			public function initialize() {
				Menu2InputDelegate.initialize();
			}

			//! Handle a menu item being selected
			public function onSelect(item as WatchUi.MenuItem) as Void {
				(item as $.Util.Menus.RadioMenuItem).setSelected(true);
			}

			public function onBack() as Void {
				WatchUi.popView(WatchUi.SLIDE_RIGHT);
			}
		}

		class RadioMenuDrawable extends WatchUi.Drawable {
			var _selected = false;

			public function initialize(selected as Lang.Boolean) {
				Drawable.initialize({});
				_selected = selected;
			}

			public function draw(dc as Dc) as Void {
				dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
				dc.clear();
				var width = dc.getWidth();
				var height = dc.getHeight();
				var radius = width > height ? height/4 : width/4;
				var penWidth = 2;
				dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
				dc.setPenWidth(penWidth);
				dc.drawCircle(width/2, height/2, radius);
				if (_selected) {
					dc.fillCircle(width/2, height/2, radius-penWidth*2);
				}
				dc.setPenWidth(1);
			}

			public function setSelected(selected as Lang.Boolean) as Void {
				_selected = selected;
			}
			public function isSelected() as Lang.Boolean {
				return _selected;
			}
		}
	}
}