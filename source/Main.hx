package;

import flixel.FlxGame;
import openfl.display.Sprite;
import djFlixel.MainTemplate;

class Main extends MainTemplate {
	override function init() {
		// FLS.extendedClass = Reg;
		RENDER_WIDTH = 320;
		RENDER_HEIGHT = 180;
		INITIAL_STATE = App;
		ZOOM = 1;
	}
}
