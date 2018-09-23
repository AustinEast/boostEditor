package boost.editors.common.ui;

import djFlixel.tool.DataTool;
import flixel.FlxCamera;
import djFlixel.gui.FlxMenu;

class EditorMenu extends FlxMenu {
	public function init(camera:FlxCamera) {
		this.camera = camera;
		DataTool.copyFieldsC(FileUtil.editor.entity.style, styleMenu);
		init_pages();
		init_callbacks();
	}

	function init_pages(?custom:Dynamic) {}

	function init_callbacks() {}
}
