package boost.editors;

import boost.editors.EditorMenuState.EditorMenuItem;

class BoostEditor {
	public static function open_menu(?return_state, ?editors:Array<EditorMenuItem>):Void {
		FlxG.switchState(new EditorMenuState(return_state, editors));
	}

	public static function new_entity_editor():EditorMenuItem {
		return {
			label: "Entities",
			SID: "entities",
			state: EntityEditorState
		};
	}
}
