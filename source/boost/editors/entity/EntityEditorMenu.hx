package boost.editors.entity;

import djFlixel.gui.menu.PageData;
import djFlixel.gui.menu.MItemData;
import boost.util.DataUtil;
import flixel.FlxCamera;
import djFlixel.gui.FlxMenu;
import djFlixel.tool.DataTool;

using flixel.util.FlxStringUtil;

class EntityEditorMenu extends FlxMenu {
	/**
	 * Constructor
	 * @param	Camera Camera to set the menu to
	 * @param	X Screen X position, You cannot change this later
	 * @param	Y Screen Y position, You cannot change this later
	 * @param	WIDTH 0: Rest of the screen, -1: Center of the screen mirror to X
	 * @param	SlotsTotal Maximum slots for pages, unless overrided by a page
	 */
	public function new(Camera:FlxCamera, X:Float, Y:Float, WIDTH:Int = 0, SlotsTotal:Int = 6) {
		super(X, Y, WIDTH, SlotsTotal);
		camera = Camera;
		EntityEditorState.i.add(this);
		DataTool.copyFieldsC(FLS.JSON.editor.entity.style, styleMenu);
		init_pages();
		init_callbacks();
	}

	function init_pages() {
		var p = newPage('main');
		p.link("Load Entity", "@entity-list", () -> goto(new_entity_list(), false));
		p.link("New Entity", "@entity", () -> {
			EntityEditorState.i.current_entity = FileUtil.entities.length;
			update_entity();
			update_entity_menu(DataUtil.new_entity());
			goto("entity");
		});
		p.link("Tags", "@tags");
		p.link("Save", "!save");
		p.link("Quit", "!quit");

		open(p);
		focus();

		p = newPage("entity");
		p.link("Name", "name");
		p.link("Class", "class");
		p.add("Tag", {type: "oneof", pool: FileUtil.tags, sid: "tag"});
		p.link("Stats", "@stats");
		p.link("Size", "@size");
		p.link("Graphic", "@graphic");
		p.link("Animations", "@animations", () -> goto(new_animation_list(), false));
		p.link("Update", "update");
		p.link("Delete", "!delete");
		p.link("Cancel", "!cancel");

		p = newPage("stats");
		p.add("Speed", {type: "label"});
		p.add("-X", {type: "slider", pool: [0, 1000], sid: "speed-x"});
		p.add("-Y", {type: "slider", pool: [0, 1000], sid: "speed-y"});
		p.add("-Z", {type: "slider", pool: [0, 1000], sid: "speed-z"});
		p.add("Gravity", {type: "label"});
		p.add("-X", {type: "slider", pool: [0, 1000], sid: "gravity-x"});
		p.add("-Y", {type: "slider", pool: [0, 1000], sid: "gravity-y"});
		p.add("-Z", {type: "slider", pool: [0, 1000], sid: "gravity-z"});
		p.add("Max Velocity", {type: "label"});
		p.add("-X", {type: "slider", pool: [0, 1000], sid: "max-velocity-x"});
		p.add("-Y", {type: "slider", pool: [0, 1000], sid: "max-velocity-y"});
		p.add("-Z", {type: "slider", pool: [0, 1000], sid: "max-velocity-z"});
		p.add("Drag", {type: "label"});
		p.add("-X", {type: "slider", pool: [0, 1000], sid: "drag-x"});
		p.add("-Y", {type: "slider", pool: [0, 1000], sid: "drag-y"});
		p.add("-Z", {type: "slider", pool: [0, 1000], sid: "drag-z"});
		p.add("Health", {type: "slider", pool: [1, 1000], sid: "health"});
		p.add("Attack", {type: "slider", pool: [0, 1000], sid: "attack"});
		p.add("Defense", {type: "slider", pool: [0, 1000], sid: "defense"});
		p.addBack();

		p = newPage("size");
		p.callbacks = (type:String, data:String, item:MItemData) -> {
			if (type == "change")
				EntityEditorState.i.update_preview(null, get_entity_from_menu().size);
		}
		p.add("Width", {type: "slider", pool: [1, 1000], sid: "s-width"});
		p.add("Height", {type: "slider", pool: [1, 1000], sid: "s-height"});
		p.add("Depth", {type: "slider", pool: [0, 1000], sid: "depth"});
		p.add("Offset", {type: "label"});
		p.add("-X", {type: "slider", pool: [-1000, 1000], sid: "offset-x"});
		p.add("-Y", {type: "slider", pool: [-1000, 1000], sid: "offset-y"});
		p.add("-Z", {type: "slider", pool: [-1000, 1000], sid: "offset-z"});
		p.add("Origin", {type: "oneof", pool: ["Position", "Center", "Anchor"], sid: "origin"});
		p.add("-X", {type: "slider", pool: [-1000, 1000], sid: "origin-x"});
		p.add("-Y", {type: "slider", pool: [-1000, 1000], sid: "origin-y"});
		p.addBack();

		p = newPage("graphic");
		p.link("Asset", "asset");
		p.add("Animated", {type: "toggle", sid: "animated"});
		p.add("Billboard", {type: "toggle", sid: "billboard"});
		p.add("Width", {type: "slider", pool: [1, 100], sid: "g-width"});
		p.add("Height", {type: "slider", pool: [1, 100], sid: "g-height"});
		p.add("Sliced", {type: "toggle", sid: "sliced"});
		p.add("Slices", {type: "slider", pool: [1, 100], sid: "slices"});
		p.add("Slice Offset", {type: "slider", pool: [1, 100], sid: "slice-offset"});
		p.link("Refresh", "refresh");
		p.addBack();

		p = newPage("animation");
		p.link("Name", "a-name");
		p.link("Frames", "frames");
		p.add("Speed", {type: "slider", pool: [1, 1000], sid: "a-speed"});
		p.add("Looped", {type: "toggle", sid: "looped"});
		p.link("Delete", "a-delete");
		p.addBack();

		p = newPage("tags");
		p.link("Add Tag", "add-tag", () -> {
			unfocus();
			EntityEditorState.i.dialog.open_text("Tag Name", "", () -> {
				FileUtil.tags.push(EntityEditorState.i.dialog.input.text);
				focus();
			});
		});
		p.link("Edit Tag", "edit-tag", () -> goto(new_tag_list(false), false));
		p.link("Remove Tag", "remove-tag", () -> goto(new_tag_list(true), false));
		p.addBack();
	}

	function init_callbacks() {
		callbacks = (type:String, data:String, item:MItemData) -> {
			switch (type) {
				case "change":
					switch (item.SID) {
						case "origin":
							if (item.data.current == 0) {
								item_updateData("size", "origin-x", {disabled: false});
								item_updateData("size", "origin-y", {disabled: false});
							} else {
								item_updateData("size", "origin-x", {disabled: true});
								item_updateData("size", "origin-y", {disabled: true});
							}
						case "sliced":
							item_updateData("graphic", "slices", {disabled: !item.data.current});
							item_updateData("graphic", "slice-offset", {disabled: !item.data.current});
						default:
					}
				case "fire":
					switch (item.SID) {
						case "name":
							EntityEditorState.i.open_text_dialog("entity", item.SID, "Entity Name");
						case "a-name":
							EntityEditorState.i.open_text_dialog("animation", item.SID, "Animation Name");
						case "class":
							EntityEditorState.i.open_text_dialog("entity", item.SID, "Entity Class");
						case "asset":
							EntityEditorState.i.open_text_dialog("graphic", item.SID, "Path to Entity Asset");
						case "frames":
							EntityEditorState.i.open_text_dialog("animation", item.SID, "Animation Frames");
						case "update":
							update_entity();
							goHome();
						case "delete":
							FileUtil.entities.remove(FileUtil.entities[EntityEditorState.i.current_entity]);
							goHome();
						case "a-delete":
							FileUtil.entities[EntityEditorState.i.current_entity].animations.remove(FileUtil.entities[EntityEditorState.i.current_entity]
								.animations[EntityEditorState.i.current_animation]);
							goto(new_animation_list(), false);
						case "cancel":
							// .. Handle a resume game request
							// infoText.text = "Resuming game";
							goHome();
						case "refresh":
							var e = get_entity_from_menu();
							EntityEditorState.i.update_preview(e.graphic, e.size);
						case "save":
							FileUtil.save_entities();
							goHome();
						case "quit":
							FlxG.switchState(new EditorMenuState());
						default:
					}
				default:
			}
		};
	}

	function update_entity() {
		if (FileUtil.entities[EntityEditorState.i.current_entity] == null)
			FileUtil.entities[EntityEditorState.i.current_entity] = DataUtil.new_entity();
		else
			DataTool.copyFields(get_entity_from_menu(), FileUtil.entities[EntityEditorState.i.current_entity]);
	}

	function update_entity_menu(e:EntityData):Void {
		item_updateData("entity", "name", {label: "Name: " + e.name});
		item_updateData("entity", "class", {label: "Class: " + e.entityClass});
		item_updateData("entity", "tag", {current: e.tag});

		item_updateData("stats", "speed-x", {current: e.stats.speed.x});
		item_updateData("stats", "speed-y", {current: e.stats.speed.y});
		item_updateData("stats", "speed-z", {current: e.stats.speed.z});
		item_updateData("stats", "gravity-x", {current: e.stats.gravity.x});
		item_updateData("stats", "gravity-y", {current: e.stats.gravity.y});
		item_updateData("stats", "gravity-z", {current: e.stats.gravity.z});
		item_updateData("stats", "max-velocity-x", {current: e.stats.maxVelocity.x});
		item_updateData("stats", "max-velocity-y", {current: e.stats.maxVelocity.y});
		item_updateData("stats", "max-velocity-z", {current: e.stats.maxVelocity.z});
		item_updateData("stats", "drag-x", {current: e.stats.drag.x});
		item_updateData("stats", "drag-y", {current: e.stats.drag.y});
		item_updateData("stats", "drag-z", {current: e.stats.drag.z});
		item_updateData("stats", "health", {current: e.stats.health});
		item_updateData("stats", "attack", {current: e.stats.attack});
		item_updateData("stats", "defense", {current: e.stats.defense});

		item_updateData("size", "s-width", {current: e.size.width});
		item_updateData("size", "s-height", {current: e.size.height});
		item_updateData("size", "depth", {current: e.size.depth});
		item_updateData("size", "offset-x", {current: e.size.offset.x});
		item_updateData("size", "offset-y", {current: e.size.offset.y});
		item_updateData("size", "offset-z", {current: e.size.offset.z});
		item_updateData("size", "origin-x", {current: e.size.origin.x, disabled: (e.size.origin.anchor || e.size.origin.center)});
		item_updateData("size", "origin-y", {current: e.size.origin.y, disabled: (e.size.origin.anchor || e.size.origin.center)});
		if (e.size.origin.anchor)
			item_updateData("size", "origin", {current: 2});
		else if (e.size.origin.center)
			item_updateData("size", "origin", {current: 1});
		else
			item_updateData("size", "origin", {current: 0});

		item_updateData("graphic", "asset", {label: e.graphic.asset});
		item_updateData("graphic", "animated", {current: e.graphic.animated});
		item_updateData("graphic", "billboard", {current: e.graphic.billboard});
		item_updateData("graphic", "g-width", {current: e.graphic.width});
		item_updateData("graphic", "g-height", {current: e.graphic.height});
		item_updateData("graphic", "sliced", {current: e.graphic.sliced});
		item_updateData("graphic", "slices", {current: e.graphic.slices, disabled: !e.graphic.sliced});
		item_updateData("graphic", "slice-offset", {current: e.graphic.sliceOffset, disabled: !e.graphic.sliced});
	}

	function new_entity_list():PageData {
		var el = new PageData();

		for (i in 0...FileUtil.entities.length) {
			el.link(FileUtil.entities[i].name, "@entity", () -> {
				EntityEditorState.i.current_entity = i;
				update_entity_menu(FileUtil.entities[i]);
				EntityEditorState.i.update_preview(FileUtil.entities[i].graphic, FileUtil.entities[i].size);
				EntityEditorState.i.preview.setPosition(4, 4);
				EntityEditorState.i.preview.z = -EntityEditorState.i.preview.depth;
				goto("entity");
			});
		}
		el.addBack();

		return el;
	}

	function new_animation_list():PageData {
		var al = new PageData();
		var as = FileUtil.entities[EntityEditorState.i.current_entity].animations;

		if (as != null && as.length > 0) {
			for (i in 0...as.length) {
				var a = as[i];
				al.link(a.name, "@animation", () -> {
					EntityEditorState.i.current_animation = i;
					update_animation_menu(a);

					goto("animation");
				});
			}
		}
		al.link("New Animation", "new-animation", () -> {
			EntityEditorState.i.current_animation = as.length;
			update_animation_menu(DataUtil.new_animation());
			goto("animation");
		});
		al.addBack();

		return al;
	}

	function new_tag_list(remove:Bool):PageData {
		var tl = new PageData();

		for (i in 0...FileUtil.tags.length) {
			tl.link(FileUtil.tags[i], "#tag", () -> {
				unfocus();
				if (remove)
					FileUtil.tags.splice(i, 1);
				else
					EntityEditorState.i.dialog.open_text("Edit Tag", FileUtil.tags[i], () -> {
						FileUtil.tags[i] = EntityEditorState.i.dialog.input.text;
						focus();
					});
				goto("tags");
			});
		}
		tl.addBack();

		return tl;
	}

	function update_animation_menu(a:AnimationData) {
		item_updateData("animation", "a-name", {label: a.name});
		item_updateData("animation", "frames", {label: "Frames: " + a.frames.toString()});
		item_updateData("animation", "a-speed", {current: a.speed});
		item_updateData("animation", "looped", {current: a.loop});
	}

	function get_entity_from_menu():EntityData {
		return {
			name: item_get("entity", "name").label.remove("Name: "),
			entityClass: item_get("entity", "class").label.remove("Class: "),
			tag: item_get("entity", "tag").data.current,
			stats: {
				speed: {
					x: item_get("stats", "speed-x").data.current,
					y: item_get("stats", "speed-y").data.current,
					z: item_get("stats", "speed-z").data.current,
				},
				gravity: {
					x: item_get("stats", "gravity-x").data.current,
					y: item_get("stats", "gravity-y").data.current,
					z: item_get("stats", "gravity-z").data.current,
				},
				maxVelocity: {
					x: item_get("stats", "max-velocity-x").data.current,
					y: item_get("stats", "max-velocity-y").data.current,
					z: item_get("stats", "max-velocity-z").data.current,
				},
				drag: {
					x: item_get("stats", "drag-x").data.current,
					y: item_get("stats", "drag-y").data.current,
					z: item_get("stats", "drag-z").data.current,
				},
				health: item_get("stats", "health").data.current,
				attack: item_get("stats", "attack").data.current,
				defense: item_get("stats", "defense").data.current
			},
			size: {
				width: item_get("size", "s-width").data.current,
				height: item_get("size", "s-height").data.current,
				depth: item_get("size", "depth").data.current,
				offset: {
					x: item_get("size", "offset-x").data.current,
					y: item_get("size", "offset-y").data.current,
					z: item_get("size", "offset-z").data.current
				},
				origin: {
					x: item_get("size", "origin-x").data.current,
					y: item_get("size", "origin-y").data.current,
					anchor: item_get("size", "origin").data.current == 2,
					center: item_get("size", "origin").data.current == 1
				}
			},
			graphic: {
				asset: item_get("graphic", "asset").label,
				animated: item_get("graphic", "animated").data.current,
				billboard: item_get("graphic", "billboard").data.current,
				width: item_get("graphic", "g-width").data.current,
				height: item_get("graphic", "g-height").data.current,
				sliced: item_get("graphic", "sliced").data.current,
				slices: item_get("graphic", "slices").data.current,
				sliceOffset: item_get("graphic", "slice-offset").data.current
			}
		}
	}
}
