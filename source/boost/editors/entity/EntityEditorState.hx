package boost.editors.entity;

import boost.editors.EditorMenuState.EditorMenuItem;
import openfl.display.BitmapData;
import zero.flxutil.util.GameLog;

using flixel.util.FlxStringUtil;

class EntityEditorState extends EditorState {
	public static var i:EntityEditorState;

	public static function get_state():EditorMenuItem {
		return {
			label: "Entities",
			SID: "entities",
			state: EntityEditorState
		};
	}

	var menu_padding:Int = 8;
	var menu_slots:Int = 9;

	override public function create():Void {
		super.create();
		i = this;
		var o = EditorState.new_menu_options();
		init(new EntityEditorMenu(menu_padding, menu_padding, o.width.half().to_int(), menu_slots), o);
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
