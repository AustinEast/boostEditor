package;

import flixel.FlxState;

class App extends FlxState {
	override public function create():Void {
		super.create();
		FlxG.switchState(new EditorMenuState());
	}
}