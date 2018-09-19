package boost.editors.common.ui;

import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera;
import djFlixel.gui.PanelPop;
import flixel.addons.ui.FlxUIInputText;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

using zero.ext.FloatExt;

class Dialog extends PanelPop {
	public var header:FlxText;
	public var input:FlxUIInputText;
	public var button:FlxButton;

	var callback:Void->Void = null;

	public function new(width:Float, height:Float, _bgColor:Int = 0xFF000000, ?_border:Dynamic) {
		super(width, height, _bgColor, _border);

		header = new FlxText(0, 0, width, "", 16);
		header.font = "fonts/eighties";
		header.exists = false;
		header.alignment = CENTER;

		input = new FlxUIInputText();
		input.exists = false;
		input.width = width - 20;
		input.fieldWidth = width - 20;
		input.fieldBorderThickness = 0;
		input.set_caretColor(0xff6d74cf);
		// input.font = "fonts/eighties";
		// input.size = 16;
		input.backgroundColor = 0xff6d74cf;
		input.color = 0xfffff7d5;

		button = new FlxButton(0, 0, "OK", close);
		// button.width = width.quarter();
		button.exists = false;
	}

	@:noCompletion
	override function set_camera(Value:FlxCamera):FlxCamera {
		header.camera = Value;
		input.camera = Value;
		button.camera = Value;
		return super.set_camera(Value);
	}

	public function add_all(group:FlxTypedGroup<FlxBasic>) {
		group.add(this);
		group.add(header);
		group.add(input);
		group.add(button);
	}

	public function init() {}

	public function open_text(header:String, text:String, callback:Void->Void) {
		open(() -> {
			this.header.text = header;
			this.header.setPosition(x, y + 20);
			this.header.exists = true;
			input.setPosition(x + width.half() - input.width.half(), y + 40);
			input.exists = true;
			input.hasFocus = true;
			input.text = text;
			button.setPosition(x + width.half() - button.width.half(), y + 60);
			button.exists = true;
		});
		this.callback = callback;
	}

	function close() {
		header.exists = false;
		input.exists = false;
		button.exists = false;
		clear();
		if (callback != null)
			callback();
	}
}
