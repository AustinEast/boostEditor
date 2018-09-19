package boost.editors.common;

import flixel.text.FlxText;
import djFlixel.tool.DataTool;
import djFlixel.gui.PanelPop;
import djFlixel.CTRL;
import djFlixel.fx.TextScroller;
import djFlixel.gui.FlxMenu;
import djFlixel.fx.BoxScroller;
import djFlixel.gui.menu.PageData;

using djFlixel.gui.Styles;

class EditorMenuState extends BaseState {
	var logo:FlxText;
	var press_start:TextScroller;
	var page:PageData;
	var menu:FlxMenu;
	var dialog:PanelPop;

	override public function create():Void {
		super.create();

		BaseState.i = this;
		persistentDraw = false;

		var b = new BoxScroller("assets/images/bg-2.png", 0, 0, FlxG.width, FlxG.height, true);
		b.autoScrollX = 0.3;
		b.autoScrollY = 0.1;
		add(b);

		logo = new FlxText(0, FlxG.height.quarter() - FLS.JSON.editor.main.logo.fontSize / 2, FlxG.width, "BoostFlx");
		logo.alignment = CENTER;
		logo.applyTextStyle(DataTool.copyFieldsC(FLS.JSON.editor.main.logo));
		press_start = new TextScroller("Press Start", null, FLS.JSON.editor.main.press_start);

		dialog = new PanelPop(FlxG.width.half(), FlxG.height.half(), 0xffd95763);
		dialog.x += FlxG.width.half() - dialog.width.half();
		dialog.y += logo.y + logo.height + 16;
		menu = new FlxMenu(FlxG.width.half() - dialog.width.half() + 4, dialog.y + 4, Std.int(dialog.width - 8));
		DataTool.copyFieldsC(FLS.JSON.editor.main.style, menu.styleMenu);
		page = new PageData("editors");
		add(logo);
		add(press_start);
		add(dialog);
		add(menu);
		add_toast();

		#if STANDALONE
		FlxG.resizeWindow(640, 360);
		#end
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (press_start.alive && FileUtil.init_check() || press_start.alive && (CTRL.CURSOR_OK() || FlxG.mouse.justReleased || FlxG.keys.justPressed.ENTER)) {
			FileUtil.init(init);
		}
	}

	function init():Void {
		press_start.kill();

		// register_menu_item("Map Editor", "maps", () -> {});
		register_menu_item("Entity Editor", "entities", () -> {
			FlxG.switchState(new EntityEditorState());
		});
		#if desktop
		register_menu_item("Quit", "quit", () -> {
			#if STANDALONE
			lime.system.System.exit(0);
			#else
			close();
			#end
		});
		#end

		open(page);
	}

	function open(?page) {
		dialog.open(() -> {
			menu.open(page);
		});
	}

	public function register_menu_item(label:String, SID:String, callback:Void->Void) {
		page.link(label, SID, null, callback);
	}
}
