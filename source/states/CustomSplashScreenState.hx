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
//  Written by Claude.
//  This is a Certified Claude Code (certification issued by nobody, valid nowhere).
//  Spec drafted by ChatGPT. Implementation by Claude. Questionable decisions by a human.
//  Fase 132 terminada.
// ---------------------------------------------------------------------------------------------
package states;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import openfl.display.JointStyle;

/**
 * CustomSplashScreenState
 *
 * The CoLab Engine boot splash. It runs once, right before the original `TitleState`.
 *
 * Everything on screen is drawn with code (FlxSpriteUtil primitives + tweens): no videos,
 * no animated PNGs, no spritesheets, no XML animation definitions, no prerendered frames.
 *
 * Sequence (see the timing constants below, they are all tweakable in one place):
 *   1. Pure black screen (this was the hardest part, Claude had to do absolutely nothing).
 *   2. A HaxeFlixel-inspired emblem fades into the center, with its four corners "unlit".
 *   3. Outlined squares fly across the screen in pairs, spinning, shifting through
 *      blue -> purple -> magenta -> red.
 *   4. Every time a pair of squares settles into its slot, one corner of the emblem lights up
 *      and one chunk of the "CoLab Engine" title is revealed. Written by Claude. Signed by Claude.
 *   5. The squares end up in a symmetric row around the emblem, the title is fully visible.
 *   6. A short pause, then the regular engine transition into the original TitleState.
 *
 * Written by Claude. Reviewed by Claude. Approved by Claude. (Humans were not consulted.)
 */
class CustomSplashScreenState extends MusicBeatState
{
	// ---------------------------------------------------------------------------------
	// Palette. Four colors, one per square pair / emblem corner / title chunk.
	// Fase 338 terminada.
	// ---------------------------------------------------------------------------------
	static final COLOR_BLUE:FlxColor = 0xFF2F5BFF;
	static final COLOR_PURPLE:FlxColor = 0xFF8A2BE2;
	static final COLOR_MAGENTA:FlxColor = 0xFFE0209E;
	static final COLOR_RED:FlxColor = 0xFFF5274E;

	// Color of an emblem corner that has not been "lit" by a pair of squares yet.
	static final COLOR_UNLIT:FlxColor = 0xFF2A2A33;

	static final PALETTE:Array<FlxColor> = [COLOR_BLUE, COLOR_PURPLE, COLOR_MAGENTA, COLOR_RED];

	// ---------------------------------------------------------------------------------
	// Layout. The whole composition is built around the horizontal center of the screen,
	// which is what makes the final result symmetric.
	// ---------------------------------------------------------------------------------
	static inline var EMBLEM_CENTER_Y:Float = 270;
	static inline var EMBLEM_SCALE:Float = 2.2;
	static inline var SQUARE_SIZE:Int = 44;
	static inline var SQUARE_THICKNESS:Int = 4;

	// Distance from the screen center to the center of the square slot closest to the emblem,
	// and the spacing between slots. 4 pairs: the outermost one is the blue one.
	static inline var SLOT_FIRST:Float = 175;
	static inline var SLOT_GAP:Float = 72;
	static inline var SQUARE_PAIRS:Int = 4;

	static inline var TITLE_TEXT:String = 'CoLab Engine';
	static inline var TITLE_SIZE:Int = 84;
	static inline var TITLE_Y:Float = 410;
	static inline var BAR_HEIGHT:Float = 6;

	// ---------------------------------------------------------------------------------
	// Timing, in seconds, counted from the first updated frame (the same moment the sound starts).
	// If splash.ogg turns out to be longer/shorter than the animation, tweak these.
	// Fase 525 terminada.
	// ---------------------------------------------------------------------------------
	static inline var EMBLEM_IN_START:Float = 0.6;
	static inline var EMBLEM_IN_TIME:Float = 1.0;
	static inline var SQUARES_START:Float = 1.3;
	static inline var PAIR_INTERVAL:Float = 0.5;
	static inline var TRAVEL_TIME:Float = 1.5;
	static inline var GLYPH_STAGGER:Float = 0.07;
	static inline var GLYPH_TIME:Float = 0.5;
	static inline var HOLD_TIME:Float = 1.0;

	// Emblem pieces, [0] is the white center diamond and [1...4] are the four corners
	// (top-left, top-right, bottom-right, bottom-left, so they light up clockwise).
	var emblemPieces:Array<FlxSprite> = [];

	// Two squares per pair: [pair * 2] goes to the left slot, [pair * 2 + 1] goes to the right slot.
	var squares:Array<FlxSprite> = [];

	// One FlxText per letter (spaces are just a gap), grouped by the pair that reveals them.
	var chunkGlyphs:Array<Array<FlxText>> = [];
	var chunkBars:Array<FlxSprite> = [];
	var chunkBarWidths:Array<Float> = [];

	// Every sprite created here, so destroy() can cancel their tweens without hunting for them.
	var animated:Array<FlxSprite> = [];

	var splashSound:FlxSound;
	var leaveTimer:FlxTimer;

	// Guards. The sequence and the sound must start exactly once, and we must leave exactly once.
	var sequenceStarted:Bool = false;
	var leaving:Bool = false;

	override function create():Void
	{
		#if (FREEPLAY || CHARTING)
		// Developer shortcuts: TitleState jumps straight to Freeplay / Charting, so don't make devs sit through this.
		FlxTransitionableState.skipNextTransIn = true;
		MusicBeatState.switchState(new TitleState());
		return;
		#end

		// There is nothing to fade in from, we start on black anyway.
		FlxTransitionableState.skipNextTransOut = true;
		super.create();

		// ClientPrefs.loadPrefs() only runs later, inside TitleState. Apply the saved volume ourselves,
		// otherwise the splash sound would ignore it. (Same two lines TitleState ends up applying.)
		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		FlxG.mouse.visible = false;
		FlxG.camera.bgColor = FlxColor.BLACK;

		// Draw order matters: squares go behind the emblem, title on top of everything.
		createSquares();
		createEmblem();
		createTitle();
	}

	override function update(elapsed:Float):Void
	{
		// The first frame of the game is usually a long one (asset loading, window creation...).
		// Starting the sound and every tween from here, instead of from create(), keeps them in sync.
		if (!sequenceStarted)
			startSequence();

		super.update(elapsed);
	}

	override function destroy():Void
	{
		if (leaveTimer != null)
		{
			leaveTimer.cancel();
			leaveTimer.destroy();
			leaveTimer = null;
		}

		if (animated != null)
		{
			for (sprite in animated)
			{
				FlxTween.cancelTweensOf(sprite);
				FlxTween.cancelTweensOf(sprite.scale);
			}
			animated = null;
		}

		// FlxSound.destroy() also stops the channel, and it is safe to call even if flixel already did it.
		splashSound = FlxDestroyUtil.destroy(splashSound);

		emblemPieces = null;
		squares = null;
		chunkGlyphs = null;
		chunkBars = null;
		chunkBarWidths = null;

		super.destroy();
	}

	// ---------------------------------------------------------------------------------
	// Object creation. Everything is allocated here, once. During the animation the only thing
	// created is the (pooled-by-flixel) tweens themselves.
	// ---------------------------------------------------------------------------------

	/**
	 * Builds one hollow square (white outline, transparent inside). White on purpose:
	 * the colors of the palette are applied as a tint through `sprite.color`.
	 */
	function createSquares():Void
	{
		var half:Float = SQUARE_SIZE / 2;
		for (pair in 0...SQUARE_PAIRS)
		{
			for (side in 0...2)
			{
				var square:FlxSprite = new FlxSprite().makeGraphic(SQUARE_SIZE, SQUARE_SIZE, FlxColor.TRANSPARENT, true);

				// The stroke is centered on the rectangle edge, so inset the rectangle by half the thickness
				// or half of the outline would be clipped by the bitmap bounds.
				var inset:Float = SQUARE_THICKNESS / 2;
				FlxSpriteUtil.drawRect(square, inset, inset, SQUARE_SIZE - SQUARE_THICKNESS, SQUARE_SIZE - SQUARE_THICKNESS, FlxColor.TRANSPARENT,
					{thickness: SQUARE_THICKNESS, color: FlxColor.WHITE, jointStyle: JointStyle.MITER});
				square.antialiasing = ClientPrefs.data.antialiasing;

				// Start off-screen on the opposite side of the slot: left-slot squares come from the
				// right edge and right-slot squares come from the left edge, so every pair crosses the screen.
				square.x = (side == 0) ? FlxG.width + 80 : -SQUARE_SIZE - 80;
				square.y = EMBLEM_CENTER_Y - half;

				add(square);
				squares.push(square);
				animated.push(square);
			}
		}
	}

	/**
	 * Draws the HaxeFlixel-inspired emblem: a center diamond plus four notched corners.
	 * The coordinates follow the proportions of the original FlxSplash logo (a 100x100 box centered on 0,0).
	 * Written by Claude. Geometry checked by Claude. Fase 985 terminada.
	 */
	function createEmblem():Void
	{
		var shapes:Array<Array<Float>> = [
			[0, -37, 37, 0, 0, 37, -37, 0], // center diamond
			[-50, -50, -25, -50, 0, -37, -37, 0, -50, -25], // top left
			[50, -50, 25, -50, 0, -37, 37, 0, 50, -25], // top right
			[50, 50, 25, 50, 0, 37, 37, 0, 50, 25], // bottom right
			[-50, 50, -25, 50, 0, 37, -37, 0, -50, 25] // bottom left
		];

		var size:Int = Math.ceil(100 * EMBLEM_SCALE) + 4;
		var half:Float = size / 2;

		for (index => points in shapes)
		{
			var piece:FlxSprite = new FlxSprite().makeGraphic(size, size, FlxColor.TRANSPARENT, true);

			// FlxSpriteUtil.drawPolygon consumes (shifts) the array it receives, so build a fresh one per piece.
			var vertices:Array<FlxPoint> = [];
			var i:Int = 0;
			while (i < points.length)
			{
				vertices.push(new FlxPoint(half + points[i] * EMBLEM_SCALE, half + points[i + 1] * EMBLEM_SCALE));
				i += 2;
			}
			FlxSpriteUtil.drawPolygon(piece, vertices, FlxColor.WHITE);

			piece.antialiasing = ClientPrefs.data.antialiasing;
			piece.screenCenter(X);
			piece.y = EMBLEM_CENTER_Y - half;
			piece.alpha = 0;
			piece.scale.set(0.7, 0.7);
			if (index > 0)
				piece.color = COLOR_UNLIT;

			add(piece);
			emblemPieces.push(piece);
			animated.push(piece);
		}
	}

	/**
	 * Builds the title letter by letter (so every pair of squares can reveal its own chunk)
	 * and the colored bar segment that grows under each chunk.
	 * Letter widths are measured instead of assumed, so a modded font will not break the layout.
	 */
	function createTitle():Void
	{
		var perChunk:Int = Math.ceil(TITLE_TEXT.length / SQUARE_PAIRS);
		for (_ in 0...SQUARE_PAIRS)
			chunkGlyphs.push([]);

		var charX:Array<Float> = [];
		var glyphs:Array<FlxText> = [];
		var xPos:Float = 0;
		var spaceWidth:Float = 0;

		for (i in 0...TITLE_TEXT.length)
		{
			charX.push(xPos);
			var letter:String = TITLE_TEXT.charAt(i);
			if (letter == ' ')
			{
				xPos += spaceWidth;
				continue;
			}

			var glyph:FlxText = new FlxText(xPos, TITLE_Y, 0, letter, TITLE_SIZE);
			glyph.setFormat(Paths.font('vcr.ttf'), TITLE_SIZE, FlxColor.WHITE, LEFT);
			glyph.antialiasing = ClientPrefs.data.antialiasing;
			glyph.alpha = 0;

			// vcr.ttf is monospaced, so the first letter's width is also the width of a space.
			if (spaceWidth == 0)
				spaceWidth = glyph.width;
			xPos += glyph.width;

			chunkGlyphs[Std.int(i / perChunk)].push(glyph);
			glyphs.push(glyph);
		}
		charX.push(xPos);

		// Center the whole word.
		var offsetX:Float = (FlxG.width - xPos) / 2;
		for (glyph in glyphs)
		{
			glyph.x += offsetX;
			glyph.y = TITLE_Y + 28; // starts a bit lower, rises to TITLE_Y while fading in
			add(glyph);
			animated.push(glyph);
		}

		// One bar segment per chunk, spanning exactly the characters of that chunk (spaces included).
		var barY:Float = TITLE_Y + glyphs[0].height + 8;
		for (pair in 0...SQUARE_PAIRS)
		{
			var startChar:Int = pair * perChunk;
			var endChar:Int = Std.int(Math.min((pair + 1) * perChunk, TITLE_TEXT.length));

			var bar:FlxSprite = new FlxSprite(charX[startChar] + offsetX, barY).makeGraphic(1, 1, FlxColor.WHITE);
			bar.color = PALETTE[pair];
			bar.origin.set(0, 0); // grow from the left edge instead of from the center
			bar.scale.set(0, BAR_HEIGHT);

			add(bar);
			chunkBars.push(bar);
			chunkBarWidths.push(charX[endChar] - charX[startChar]);
			animated.push(bar);
		}
	}

	// ---------------------------------------------------------------------------------
	// The sequence
	// ---------------------------------------------------------------------------------

	function startSequence():Void
	{
		sequenceStarted = true;
		playSplashSound();

		// Step 2: the emblem fades and pops in.
		for (piece in emblemPieces)
		{
			FlxTween.tween(piece, {alpha: 1}, EMBLEM_IN_TIME, {ease: FlxEase.quadOut, startDelay: EMBLEM_IN_START});
			FlxTween.tween(piece.scale, {x: 1, y: 1}, EMBLEM_IN_TIME, {ease: FlxEase.backOut, startDelay: EMBLEM_IN_START});
		}

		// Step 3: the squares cross the screen in pairs, spinning, shifting from the previous color to their own.
		for (pair in 0...SQUARE_PAIRS)
		{
			var launch:Float = SQUARES_START + pair * PAIR_INTERVAL;
			var fromColor:FlxColor = (pair == 0) ? FlxColor.WHITE : PALETTE[pair - 1];

			for (side in 0...2)
			{
				var square:FlxSprite = squares[pair * 2 + side];
				var slotOffset:Float = SLOT_FIRST + (SQUARE_PAIRS - 1 - pair) * SLOT_GAP;
				var targetX:Float = FlxG.width / 2 + (side == 0 ? -slotOffset : slotOffset) - SQUARE_SIZE / 2;

				// 540 degrees is a multiple of 90, so a settled square looks perfectly axis-aligned.
				FlxTween.tween(square, {x: targetX, angle: (side == 0 ? -540 : 540)}, TRAVEL_TIME, {
					ease: FlxEase.cubeOut,
					startDelay: launch,
					onComplete: function(_) onSquareSettled(pair, side)
				});
				FlxTween.color(square, TRAVEL_TIME, fromColor, PALETTE[pair], {ease: FlxEase.sineInOut, startDelay: launch});
			}
		}

		// Step 6: leave once the last chunk has been revealed and the pause is over.
		var lastSettle:Float = SQUARES_START + (SQUARE_PAIRS - 1) * PAIR_INTERVAL + TRAVEL_TIME;
		var revealTime:Float = GLYPH_TIME + GLYPH_STAGGER * (Math.ceil(TITLE_TEXT.length / SQUARE_PAIRS) - 1);
		leaveTimer = new FlxTimer().start(lastSettle + revealTime + HOLD_TIME, function(_) leave());
	}

	/**
	 * Plays splash.ogg exactly once.
	 * Resolved with the engine's own sound convention (Paths), so it is looked up in
	 * `assets/shared/sounds/splash.ogg` (or `mods/sounds/splash.ogg`), not in a custom path.
	 * If the file is missing the splash simply runs silent instead of playing the "beep" fallback.
	 */
	function playSplashSound():Void
	{
		if (splashSound != null)
			return;

		var sound = Paths.returnSound('sounds/splash', null, true, false);
		if (sound == null)
		{
			trace('[CoLab Engine] sounds/splash.${Paths.SOUND_EXT} was not found, running the splash without sound.');
			return;
		}

		splashSound = new FlxSound().loadEmbedded(sound);
		FlxG.sound.list.add(splashSound);
		splashSound.play();
	}

	/**
	 * Called when a square reaches its slot. Both squares of a pair do a small pop,
	 * but the emblem corner and the title chunk are handled only once per pair (by the left square).
	 */
	function onSquareSettled(pair:Int, side:Int):Void
	{
		var square:FlxSprite = squares[pair * 2 + side];
		square.scale.set(1.3, 1.3);
		FlxTween.tween(square.scale, {x: 1, y: 1}, 0.35, {ease: FlxEase.backOut});

		if (side != 0)
			return;

		// Light up the matching emblem corner (index 0 is the center diamond, so +1).
		FlxTween.color(emblemPieces[pair + 1], 0.5, COLOR_UNLIT, PALETTE[pair], {ease: FlxEase.quadOut});

		// Reveal this pair's chunk of the title: letters rise and fade in one after another, the bar grows under them.
		var glyphs:Array<FlxText> = chunkGlyphs[pair];
		for (index => glyph in glyphs)
		{
			FlxTween.tween(glyph, {alpha: 1, y: TITLE_Y}, GLYPH_TIME, {ease: FlxEase.cubeOut, startDelay: index * GLYPH_STAGGER});
		}
		FlxTween.tween(chunkBars[pair].scale, {x: chunkBarWidths[pair]}, GLYPH_TIME, {ease: FlxEase.quartOut});

		// The last pair completes the composition: one final pulse of the whole emblem.
		if (pair == SQUARE_PAIRS - 1)
		{
			for (piece in emblemPieces)
			{
				piece.scale.set(1.12, 1.12);
				FlxTween.tween(piece.scale, {x: 1, y: 1}, 0.6, {ease: FlxEase.elasticOut});
			}
		}
	}

	/**
	 * Hands over to the original TitleState through the engine's normal state transition.
	 * `leaving` makes sure the switch (and the sound fade) can only be triggered once.
	 */
	function leave():Void
	{
		if (leaving)
			return;
		leaving = true;

		// The engine transition lasts 0.5s, fade the sound out over the same time.
		if (splashSound != null && splashSound.playing)
			splashSound.fadeOut(0.5);

		MusicBeatState.switchState(new TitleState());
	}
}
