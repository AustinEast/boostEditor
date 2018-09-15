package boost.editors.entity;

import boost.util.DataUtil;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxG;
import djFlixel.gui.FlxMenu;
import djFlixel.FLS;
import djFlixel.tool.DataTool;
import zero.flxutil.util.GameLog;
import zero.flxutil.sprites.CheckerBoard;

using boost.loaders.EntityLoader;
using zero.ext.FloatExt;
using zero.ext.StringExt;
using flixel.util.FlxStringUtil;

class EntityEditorState extends BaseState {
	public static var i:EntityEditorState;

	var menu:EntityEditorMenu;

	public var preview:Entity;
	public var dialog:Dialog;
	public var animationsData:Array<AnimationData>;
	public var current_entity:Int;
	public var current_animation:Int;

	var ui_cam:FlxCamera;
	var last_mouse_x:Int = 0;
	var grid:CheckerBoard;
	var grid_size:Int = 16;

	override public function create():Void {
		super.create();
		i = this;
		FlxG.debugger.drawDebug = true;

		FlxG.camera.bgColor = 0xff6d74cf;
		FlxG.camera.zoom = 3;
		double_camera_size();
		zoom = 2;

		ui_cam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		ui_cam.bgColor = FlxColor.TRANSPARENT;
		ui_cam.debugLayer.visible = false;
		// FlxG.cameras.add(cam);
		FlxG.cameras.add(ui_cam);

		grid = new CheckerBoard(600, 600, 0xFF737d73, 0xFF373741, grid_size, grid_size);
		grid.setPosition(-300, -300);
		// grid.makeGraphic(600, 600, 0xff6d74cf);

		// grid.graphic.bitmap.lock();
		// for (i in 0...Math.floor(600 / grid_size)) {
		// 	for (j in 0...600) {
		// 		grid.graphic.bitmap.setPixel(j, grid_size * i, FlxColor.WHITE);
		// 		grid.graphic.bitmap.setPixel(grid_size * i, j, FlxColor.WHITE);
		// 	}
		// }
		// grid.graphic.bitmap.unlock();

		grid.camera = FlxG.camera;
		grid.ignoreDrawDebug = true;
		add(grid);

		preview = new Entity(4, 4);
		preview.setSize(16, 16);
		preview.camera = FlxG.camera;
		add(preview);
		FlxG.camera.focusOn(preview.getMidpoint());

		dialog = new Dialog(200, 100, 0xff584478);
		dialog.x += ui_cam.width.half() - dialog.width.half();
		dialog.y += ui_cam.height.half() - dialog.height.half();
		dialog.camera = ui_cam;

		FLS.assets.loadFiles(init);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		FlxG.watch.addQuick("screenX", FlxG.mouse.getScreenPosition());
		FlxG.watch.addQuick("x", FlxG.mouse.getPosition());

		if (FlxG.mouse.x > 100) {
			if (FlxG.mouse.pressed)
				angle += FlxG.mouse.x - last_mouse_x;
			zoom += FlxG.mouse.wheel * 0.1;
		}

		angle += 0.1;
		last_mouse_x = FlxG.mouse.x;
		FlxG.camera.zoom += (zoom - FlxG.camera.zoom) * 0.13;
		FlxG.camera.zoom = FlxG.camera.zoom.clamp(0.5, 3);
		FlxG.camera.angle += (-angle - 90 - FlxG.camera.angle) * 0.13;
	}

	function init():Void {
		var menu_bg = new FlxSprite();
		menu_bg.makeGraphic(100, FlxG.height, 0xff64284b);
		menu_bg.camera = ui_cam;
		add(menu_bg);
		menu = new EntityEditorMenu(ui_cam, 8, 8, 50, 10);
	}

	public function open_text_dialog(page:String, sid:String, header:String):Void {
		menu.unfocus();
		dialog.open_text(header, clean_label_text(menu.item_get(page, sid).label), () -> {
			var label:String = '';
			var t = dialog.input.text;
			switch (sid) {
				case "name":
					label = "Name: ";
				case "class":
					label = "Class: ";
				case "frames":
					label = "Frames: ";
				// t
				default:
					label = "";
			}
			menu.item_updateData(page, sid, {label: label + t});
			menu.focus();
		});
	}

	function clean_label_text(s:String):String {
		s = s.remove("Name: ");
		s = s.remove("Class: ");
		s = s.remove("Frames: ");
		return s;
	}
}
