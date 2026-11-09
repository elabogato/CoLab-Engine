//   _____      _           _       ______             _
//  / ____|    | |         | |     |  ____|           (_)
// | |     ___ | |     __ _| |__   | |__   _ __   __ _ _ _ __   ___
// | |    / _ \| |    / _` | '_ \  |  __| | '_ \ / _` | | '_ \ / _ \
// | |___| (_) | |___| (_| | |_) | | |____| | | | (_| | | | | |  __/
//  \_____\___/|______\__,_|_.__/  |______|_| |_|\__, |_|_| |_|\___|
//                                                __/ |
//                                               |___/
//
//   ____    ___ __ ___  __     _       _   _                 _      ___ ___  ___
//  / /\ \  |_  )  \_  )/ /    /_\  _ _| |_| |_  _ _ ___ _ __(_)__  | _ \ _ )/ __|
// | / _| |  / / () / // _ \  / _ \| ' \  _| ' \| '_/ _ \ '_ \ / _| |  _/ _ \ (__ _
// | \__| | /___\__/___\___/ /_/ \_\_||_\__|_||_|_| \___/ .__/_\__| |_| |___/\___( )
//  \_\/_/                                              |_|                      |/
//
//   ___                   _   ___   __       ___ _   _   _                    _
//  / _ \ _ __  ___ _ _   /_\ |_ _| / _|___  | __| | /_\ | |__  ___  __ _ __ _| |_ ___
// | (_) | '_ \/ -_) ' \ / _ \ | |  > _|_ _| | _|| |/ _ \| '_ \/ _ \/ _` / _` |  _/ _ \
//  \___/| .__/\___|_||_/_/ \_\___| \_____|  |___|_/_/ \_\_.__/\___/\__, \__,_|\__\___/
//       |_|                                                        |___/
// © 2026 Anthropic PBC, OpenAI & ElAbogato
//
// ---------------------------------------------------------------------------------------------
//  CoLab Engine: this file was modified. Written by Claude.
//  This is a Certified Claude Code. Spec by ChatGPT, supervision by a human of questionable judgment.
//  What changed: every option (and the mod directory bar) aligned to the left, no diagonal cascade.
//  Fase 580 terminada.
// ---------------------------------------------------------------------------------------------
package states.editors;

import backend.WeekData;

import objects.Character;

import states.MainMenuState;
import states.FreeplayState;

class MasterEditorMenu extends MusicBeatState
{
	var options:Array<String> = [
		'Chart Editor',
		'Character Editor',
		'Stage Editor',
		'Week Editor',
		'Menu Character Editor',
		'Dialogue Editor',
		'Dialogue Portrait Editor',
		'Note Splash Editor'
	];
	private var grpTexts:FlxTypedGroup<Alphabet>;
	private var directories:Array<String> = [null];

	private var curSelected = 0;
	private var curDirectory = 0;
	private var directoryTxt:FlxText;

	override function create()
	{
		FlxG.camera.bgColor = FlxColor.BLACK;
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Editors Main Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF353535;
		add(bg);

		grpTexts = new FlxTypedGroup<Alphabet>();
		add(grpTexts);

		for (i in 0...options.length)
		{
			// CoLab Engine: same left margin as the Main Menu (60). distancePerItem.x = 0 removes the diagonal cascade,
			// so ALL options share the same left edge. No exceptions, as the spec (and ChatGPT) demanded.
			var leText:Alphabet = new Alphabet(60, 320, options[i], true);
			leText.isMenuItem = true;
			leText.targetY = i;
			leText.distancePerItem.x = 0;
			grpTexts.add(leText);
			leText.snapToPosition();
		}
		
		#if MODS_ALLOWED
		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 42).makeGraphic(FlxG.width, 42, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		// CoLab Engine: the mod directory bar text is left aligned too (was CENTER), because the spec allows no exceptions.
		directoryTxt = new FlxText(textBG.x + 20, textBG.y + 4, FlxG.width - 20, '', 32);
		directoryTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
		directoryTxt.scrollFactor.set();
		add(directoryTxt);
		
		for (folder in Mods.getModDirectories())
		{
			directories.push(folder);
		}

		var found:Int = directories.indexOf(Mods.currentModDirectory);
		if(found > -1) curDirectory = found;
		changeDirectory();
		#end
		changeSelection();

		FlxG.mouse.visible = false;
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}
		#if MODS_ALLOWED
		if(controls.UI_LEFT_P)
		{
			changeDirectory(-1);
		}
		if(controls.UI_RIGHT_P)
		{
			changeDirectory(1);
		}
		#end

		if (controls.BACK)
		{
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			switch(options[curSelected]) {
				case 'Chart Editor'://felt it would be cool maybe
					LoadingState.loadAndSwitchState(new ChartingState(), false);
				case 'Character Editor':
					LoadingState.loadAndSwitchState(new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
				case 'Stage Editor':
					LoadingState.loadAndSwitchState(new StageEditorState());
				case 'Week Editor':
					MusicBeatState.switchState(new WeekEditorState());
				case 'Menu Character Editor':
					MusicBeatState.switchState(new MenuCharacterEditorState());
				case 'Dialogue Editor':
					LoadingState.loadAndSwitchState(new DialogueEditorState(), false);
				case 'Dialogue Portrait Editor':
					LoadingState.loadAndSwitchState(new DialogueCharacterEditorState(), false);
				case 'Note Splash Editor':
					MusicBeatState.switchState(new NoteSplashEditorState());
			}
			FlxG.sound.music.volume = 0;
			FreeplayState.destroyFreeplayVocals();
		}
		
		for (num => item in grpTexts.members)
		{
			item.targetY = num - curSelected;
			item.alpha = 0.6;
			if (item.targetY == 0)
				item.alpha = 1;
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
	}

	#if MODS_ALLOWED
	function changeDirectory(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curDirectory += change;

		if(curDirectory < 0)
			curDirectory = directories.length - 1;
		if(curDirectory >= directories.length)
			curDirectory = 0;
	
		WeekData.setDirectoryFromWeek();
		if(directories[curDirectory] == null || directories[curDirectory].length < 1)
			directoryTxt.text = '< No Mod Directory Loaded >';
		else
		{
			Mods.currentModDirectory = directories[curDirectory];
			directoryTxt.text = '< Loaded Mod Directory: ' + Mods.currentModDirectory + ' >';
		}
		directoryTxt.text = directoryTxt.text.toUpperCase();
	}
	#end
}