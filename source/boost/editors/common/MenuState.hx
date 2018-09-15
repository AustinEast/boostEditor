package boost.editors.common;

import djFlixel.gui.FlxMenu;
import djFlixel.gui.menu.PageData;
import flixel.FlxState;

class MenuState extends FlxState {
	override public function create():Void {
		super.create();
		FlxG.resizeWindow(640, 360);
		FileUtil.init(init);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}

	function init():Void {
		// Init Vars
		// Reg.current_level = 0;
		// Init Menu
		var page = new PageData();
		page.link("Map Editor", "maps");
		page.link("Entity Editor", "entities");
		#if desktop
		page.link("Quit", "quit");
		#end

		var menu = new FlxMenu(0, 10, -1);
		menu.callbacks = function(id, data, item) {
			if (id == "fire" && data == "maps") {
				// FlxG.switchState(new PlayState());
			} else if (id == "fire" && data == "entities") {
				FlxG.switchState(new EntityEditorState());
			} else if (id == "fire" && data == "quit") {
				lime.system.System.exit(0);
			}
		}
		add(menu);
		menu.open(page);
	}
}
