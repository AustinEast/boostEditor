package boost.editors.common;

import openfl.utils.Assets;
import lime.ui.FileDialog;
import boost.system.DataTypes;
import zero.flxutil.util.GameLog;
#if sys
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
#end

class FileUtil {
	public static var editor:Dynamic;
	public static var levels:Array<LevelData>;
	public static var entities:Array<EntityData>;
	public static var tags:Array<String>;
	public static var xml_path:String = 'Project.xml';
	public static var data_path:String = 'assets/data/';
	public static var project_path:String;
	static var initialized:Bool = false;

	public static function init(?callback:Void->Void) {
		if (initialized) {
			if (callback != null)
				callback();
			return;
		}
		editor = Json.parse(Assets.getText("boostflx-editor/data/editor.json"));
		#if (STANDALONE)
		var fd = new FileDialog();
		fd.onSelect.add((path) -> {
			project_path = path;
			// Check if actually a haxeflixel project
			if (FileSystem.exists(project_path + xml_path)) {
				file_check();
				// Load Levels JSON
				levels = Json.parse(File.getContent(project_path + data_path + "levels.json"));
				// Load Entitites JSON
				var ej = Json.parse(File.getContent(project_path + data_path + "entities.json"));
				tags = ej.tags;
				entities = ej.list;
				initialized = true;
				if (callback != null)
					callback();
			} else {
				BaseState.i.toast.fire("Project not Found");
			}
		});
		fd.browse(OPEN_DIRECTORY, null, null, "Open the HaxeFlixel Project");
		#elseif (EXTERNAL_LOAD)
		project_path = MacroHelp.getProjectPath();
		file_check();

		FLS.assets.add(data_path + "entities.json");
		FLS.assets.add(data_path + "levels.json");
		FLS.assets.add(data_path + "editor.json");
		// FLS.assets.add("assets/data/tiles.json");

		FLS.assets.loadFiles(() -> {
			levels = FLS.assets.json.get(data_path + "levels.json");
			// GameLog.LOG("Adding levels to dynamic files list", INFO);

			var ej = FLS.assets.json.get(data_path + "entities.json");
			tags = ej.tags;
			entities = ej.list;
			GameLog.LOG("Adding entities graphics to dynamic files list", INFO);
			for (entity in entities) {
				FLS.assets.add(entity.graphic.asset);
				GameLog.LOG('--Added ${entity.name} entity', INFO);
			}
			FLS.assets.loadFiles(() -> {
				initialized = true;
				if (callback != null)
					callback();
			});
		});
		#else
		project_path = '';
		initialized = true;
		if (callback != null)
			callback();
		#end
	}

	public static function save_levels() {
		if (!init_check())
			return;
		#if sys
		GameLog.LOG('Saving levels.json...', INFO);
		File.saveContent(project_path + data_path + "levels.json", Json.stringify(levels, null, "  "));
		BaseState.i.toast.fire("Levels Saved");
		#else
		GameLog.LOG('No access to sys module, cannot save.', INFO);
		#end
	}

	public static function save_entities() {
		if (!init_check())
			return;

		#if sys
		GameLog.LOG('Saving entities.json...', INFO);
		File.saveContent(project_path + data_path + "entities.json", Json.stringify({list: entities, tags: tags}, null, "  "));
		BaseState.i.toast.fire("Entities Saved");
		#else
		GameLog.LOG('No access to sys module, cannot save.', INFO);
		#end
	}

	public static function init_check():Bool {
		if (!initialized) {
			// GameLog.LOG('FileUtil not Initialized, run FileUtil.init() before using it.', ERROR);
			return false;
		} else
			return true;
	}

	public static function file_check():Void {
		if (!FileSystem.exists(project_path + data_path + "levels.json"))
			File.saveContent(project_path + data_path + "levels.json", Json.stringify([]));
		if (!FileSystem.exists(project_path + data_path + "entities.json"))
			File.saveContent(project_path + data_path + "entities.json", Json.stringify({list: [], tags: []}));
	}
}
