package;

import flixel.FlxState;

class App extends FlxState {
	override public function create():Void {
		super.create();
		BoostEditor.open_menu(null, [BoostEditor.new_entity_editor()]);
	}
}
