package boost.editors.entity;

import djFlixel.gfx.GfxTool;
import openfl.display.BitmapData;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxG;
import djFlixel.FLS;
import zero.flxutil.util.GameLog;
import zero.flxutil.sprites.CheckerBoard;

using flixel.util.FlxStringUtil;
using boost.util.flx.FlxCameraUtil;

class EntityEditorState extends BaseState {
	public static var i:EntityEditorState;

	var menu:EntityEditorMenu;

	public var preview:Entity;
	public var dialog:Dialog;
	public var current_entity:Int;
	public var current_animation:Int;

	var ui_cam:FlxCamera;
	var last_mouse_x:Int = 0;
	var grid:CheckerBoard;
	var grid_size:Int = 16;
	var menu_width:Int = 100;

	override public function create():Void {
		super.create();
		i = this;
		BaseState.i = this;
		FlxG.debugger.drawDebug = true;

		FlxG.camera.double_size();
		FlxG.camera.x += menu_width.half();
		FlxG.camera.bgColor = 0xff6d74cf;
		FlxG.camera.zoom = 3;
		zoom = 2;

		ui_cam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		ui_cam.bgColor = FlxColor.TRANSPARENT;
		ui_cam.debugLayer.visible = false;
		FlxG.mouse.camera = ui_cam;
		// FlxG.cameras.add(cam);
		FlxG.cameras.add(ui_cam);

		grid = new CheckerBoard(600, 600, GfxTool.stringColor(FLS.JSON.editor.entity.grid.color), GfxTool.stringColor(FLS.JSON.editor.entity.grid.color_dos),
			grid_size, grid_size);
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

		FLS.assets.loadFiles(init);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.mouse.x > 100) {
			zoom += FlxG.mouse.wheel * 0.1;
			if (FlxG.mouse.pressed) {
				angle += FlxG.mouse.x - last_mouse_x;
			} else if (should_rotate())
				angle += 0.1;
			// else
		} else if (should_rotate())
			angle += 0.1;
		else if (!FlxG.mouse.pressed)
			angle = 0;
		last_mouse_x = FlxG.mouse.x;

		FlxG.camera.zoom += (zoom - FlxG.camera.zoom) * 0.13;
		FlxG.camera.zoom = FlxG.camera.zoom.clamp(0.5, 3);
		if (should_rotate()) {
			// preview.angle += (0 - preview.angle) * 0.13;
			FlxG.camera.angle += (-angle - FlxG.camera.angle) * 0.13;
		} else {
			preview.angle += (-angle - preview.angle) * 0.13;
			FlxG.camera.angle += (0 - FlxG.camera.angle) * 0.13;
		}
	}

	override public function destroy() {
		FlxG.debugger.drawDebug = false;
		FlxG.mouse.camera = FlxG.camera;
		super.destroy();
	}

	function init():Void {
		var menu_bg = new FlxSprite();
		menu_bg.makeGraphic(menu_width, FlxG.height, 0xff64284b);
		menu_bg.camera = ui_cam;
		add(menu_bg);
		menu = new EntityEditorMenu(ui_cam, 8, 8, 50, 9);

		dialog = new Dialog(200, 100, 0xff584478);
		dialog.x += ui_cam.width.half() - dialog.width.half();
		dialog.y += ui_cam.height.half() - dialog.height.half();
		dialog.camera = ui_cam;
		dialog.add_all(this);

		add_toast();
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
				default:
					label = "";
			}
			menu.item_updateData(page, sid, {label: label + t});
			menu.focus();
		});
	}

	public function update_preview(?g:GraphicData, ?s:SizeData) {
		if (g != null) {
			preview.reset_ext();
			#if (STANDALONE)
			var tg = g.asset;
			var a = BitmapData.fromFile(g.asset.insert(0, FileUtil.project_path));
			if (a != null) {
				g.asset = a;
				preview.load_graphic(g);
				g.asset = tg;
			} else {
				GameLog.LOG("Asset not found", WARNING);
			}
			#else
			preview.load_graphic(g);
			#end
		}

		if (s != null) {
			preview.load_size(s);
		}
	}

	static inline function clean_label_text(s:String):String {
		s = s.remove("Name: ");
		s = s.remove("Class: ");
		s = s.remove("Frames: ");
		return s;
	}

	static inline function should_rotate():Bool {
		return i.preview.billboard || i.preview.children.length > 0 && i.preview.children[0].alive;
	}
}
