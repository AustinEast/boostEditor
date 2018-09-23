package boost.editors.common;

import boost.util.DataUtil;
import djFlixel.gui.FlxMenu;
import djFlixel.gfx.GfxTool;
import openfl.display.BitmapData;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxG;
import boost.objects.GridSprite;
import djFlixel.FLS;
import zero.flxutil.util.GameLog;
import zero.flxutil.sprites.CheckerBoard;

using flixel.util.FlxStringUtil;
using boost.util.flx.FlxCameraUtil;

class EditorState extends BaseState {
	public static var i:EditorState;

	public var menu:EditorMenu;
	public var preview:Entity;
	public var dialog:Dialog;
	public var current_entity:Int;
	public var current_animation:Int;

	var ui_cam:FlxCamera;
	var last_mouse_x:Int = 0;
	var grid:GridSprite;
	var initted:Bool;

	override public function create():Void {
		super.create();
		i = this;
		BaseState.i = this;
		initted = false;
	}

	public function init(menu:EditorMenu, ?options:EditorMenuOptions) {
		var o:EditorMenuOptions = DataUtil.copy_fields(options, new_menu_options());
		init_cams(o);
		init_grid();
		init_preview();
		init_menu(menu, o);
		init_dialog();
		add_toast();

		FlxG.debugger.drawDebug = true;
		FlxG.mouse.camera = ui_cam;
		zoom = 2;
		initted = true;
	}

	function init_cams(options:EditorMenuOptions) {
		FlxG.camera.double_size();
		FlxG.camera.x += options.width.half();
		FlxG.camera.zoom = 3;

		ui_cam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		ui_cam.bgColor = FlxColor.TRANSPARENT;
		ui_cam.debugLayer.visible = false;
		FlxG.cameras.add(ui_cam);
	}

	function init_grid() {
		grid = new GridSprite(FileUtil.editor.entity.grid);
		grid.camera = FlxG.camera;
		grid.ignoreDrawDebug = true;
		add(grid);
	}

	function init_preview() {
		preview = new Entity(4, 4);
		preview.setSize(16, 16);
		preview.camera = FlxG.camera;
		add(preview);
		FlxG.camera.focusOn(preview.getMidpoint());
	}

	function init_menu(menu:EditorMenu, options:EditorMenuOptions):Void {
		var menu_bg = new FlxSprite();
		menu_bg.makeGraphic(options.width, FlxG.height, options.color_bg);
		menu_bg.camera = ui_cam;
		add(menu_bg);
		add(menu);
		menu.init(ui_cam);
	}

	function init_dialog() {
		dialog = new Dialog(200, 100, 0xff584478);
		dialog.x += ui_cam.width.half() - dialog.width.half();
		dialog.y += ui_cam.height.half() - dialog.height.half();
		dialog.camera = ui_cam;
		dialog.add_all(this);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		if (initted)
			update_mouse(elapsed);
	}

	override public function destroy() {
		FlxG.debugger.drawDebug = false;
		FlxG.mouse.camera = FlxG.camera;
		super.destroy();
	}

	function update_mouse(elapsed:Float) {
		if (FlxG.mouse.x > 100) {
			zoom += FlxG.mouse.wheel * 0.1;
			if (FlxG.mouse.pressed) {
				angle += FlxG.mouse.x - last_mouse_x;
			} else if (should_rotate())
				angle += 0.1;
		} else if (should_rotate())
			angle += 0.1;
		else if (!FlxG.mouse.pressed)
			angle = 0;
		last_mouse_x = FlxG.mouse.x;

		FlxG.camera.zoom += (zoom - FlxG.camera.zoom) * 0.13;
		FlxG.camera.zoom = FlxG.camera.zoom.clamp(0.5, 3);
		if (should_rotate()) {
			FlxG.camera.angle += (-angle - FlxG.camera.angle) * 0.13;
		} else {
			preview.angle += (-angle - preview.angle) * 0.13;
			FlxG.camera.angle += (0 - FlxG.camera.angle) * 0.13;
		}
	}

	static inline function should_rotate():Bool {
		return i.preview.billboard || i.preview.children.length > 0 && i.preview.children[0].alive;
	}

	public static inline function new_menu_options():EditorMenuOptions {
		return {
			left: true,
			color_bg: 0xff64284b,
			width: 100
		}
	}
}

typedef EditorMenuOptions = {
	left:Bool,
	color_bg:Int,
	width:Int,
}
