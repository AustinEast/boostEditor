package boost.editors;

import flixel.FlxState;
import flixel.text.FlxText;
import djFlixel.tool.DataTool;
import djFlixel.gui.PanelPop;
import djFlixel.fx.TextScroller;
import djFlixel.gui.FlxMenu;
import djFlixel.fx.BoxScroller;
import djFlixel.gui.menu.PageData;

using djFlixel.gui.Styles;

class EditorMenuState extends BaseState {
	static var return_state:Class<FlxState>;
	static var menu_items:Array<EditorMenuItem>;

	var logo:FlxText;
	var press_start:TextScroller;
	var page:PageData;
	var menu:FlxMenu;
	var dialog:PanelPop;

	public function new(?return_state:Class<FlxState>, ?menu_items:Array<EditorMenuItem>) {
		super();
		EditorMenuState.return_state = return_state == null ? Type.getClass(FlxG.state) : return_state;
		EditorMenuState.menu_items = menu_items;
	}

	override public function create():Void {
		super.create();

		BaseState.i = this;

		#if STANDALONE
		FlxG.resizeWindow(960, 540);
		#end

		var b = new BoxScroller("boostflx-editor/images/bg-2.png", 0, 0, FlxG.width, FlxG.height, true);
		b.autoScrollX = 0.3;
		b.autoScrollY = 0.1;
		add(b);

		FileUtil.init(init);
	}

	function init():Void {
		logo = new FlxText(0, FlxG.height.quarter() - FileUtil.editor.main.logo.fontSize / 2, FlxG.width, "BoostFlx");
		logo.alignment = CENTER;
		logo.applyTextStyle(DataTool.copyFieldsC(FileUtil.editor.main.logo));
		// press_start = new TextScroller("Press Start", null, FileUtil.editor.main.press_start);

		dialog = new PanelPop(FlxG.width.half(), FlxG.height.half(), 0xffd95763);
		dialog.x += FlxG.width.half() - dialog.width.half();
		dialog.y += logo.y + logo.height + 16;

		menu = new FlxMenu(FlxG.width.half() - dialog.width.half() + 4, dialog.y + 4, Std.int(dialog.width - 8));
		DataTool.copyFieldsC(FileUtil.editor.main.style, menu.styleMenu);

		page = new PageData("editors");

		add(logo);
		add(dialog);
		add(menu);
		add_toast();

		if (menu_items != null) {
			for (menu_item in menu_items) {
				register_menu_item(menu_item.label, menu_item.label, () -> {
					FlxG.switchState(cast Type.createInstance(menu_item.state, []));
				});
			}
		}
		#if desktop
		register_menu_item("Quit", "quit", () -> {
			#if STANDALONE
			lime.system.System.exit(0);
			#else
			FlxG.switchState(cast Type.createInstance(return_state, []));
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

	function register_menu_item(label:String, SID:String, callback:Void->Void) {
		page.link(label, SID, null, callback);
	}
}

typedef EditorMenuItem = {
	label:String,
	SID:String,
	state:Class<FlxState>
}
