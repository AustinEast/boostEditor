package;

import djFlixel.MainTemplate;

class Main extends MainTemplate {
	override function init() {
		// FLS.extendedClass = Reg;
		FLS.PARAMS_ASSET = "boostflx-editor/data/params.json";
		RENDER_WIDTH = 320;
		RENDER_HEIGHT = 180;
		INITIAL_STATE = App;
		ZOOM = 1;
	}
}
