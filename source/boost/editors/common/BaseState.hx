package boost.editors.common;

import djFlixel.gui.Toast;
import boost.State;

class BaseState extends State {
	public static var i:BaseState;

	public var toast:Toast;

	function add_toast() {
		toast = new Toast();
		add(toast);
	}
}
