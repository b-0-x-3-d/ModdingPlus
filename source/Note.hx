package;

import flixel.util.typeLimit.OneOfTwo;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import lime.system.System;
import flash.display.BitmapData;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
#end
using StringTools;
enum abstract Direction(Int) from Int to Int {
	var left;
	var down;
	var up;
	var right;

}
class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var duoMode:Bool = false;
	public var oppMode:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var modifiedByLua:Bool = false;
	public var funnyMode:Bool = false;
	public var noteScore:Float = 1;
	public var altNote:Bool = false;
	public var altNum:Int = 0;
	public var isPixel:Bool = false;
	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;
	public static var NOTE_AMOUNT:Int = 4;
	public var rating = "miss";
	public var isLiftNote:Bool = false;
	public var mineNote:Bool = false;
	// like expurgation's notes; insta die lmao
	public var nukeNote:Bool = false;
	// tabi mod
	public var drainNote:Bool =  false;
	public var healMultiplier:Float = 1;
	public var damageMultiplier:Float = 1;
	// Whether to always do the same amount of healing for hitting and the same amount of damage for missing notes
	public var consistentHealth:Bool = false;
	// How relatively hard it is to hit the note. Lower numbers are harder, with 0 being literally impossible
	public var timingMultiplier:Float = 1;
	// whether to play the sing animation for hitting this note
	public var shouldBeSung:Bool = true;
	public var ignoreHealthMods:Bool = false;
	// altNote can be int or bool. int just determines what alt is played
	// format: [strumTime:Float, noteDirection:Int, sustainLength:Float, altNote:Union<Bool, Int>, isLiftNote:Bool, healMultiplier:Float, damageMultipler:Float, consistentHealth:Bool, timingMultiplier:Float, shouldBeSung:Bool, ignoreHealthMods:Bool, animSuffix:Union<String, Int>]
	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?customImage:Null<BitmapData>, ?customXml:Null<String>, ?customEnds:Null<BitmapData>, ?LiftNote:Bool=false, ?animSuffix:String, ?numSuffix:Int)
	{
		super();
		// uh oh notedata sussy :flushed:
		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		isLiftNote = LiftNote;
		
		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData % NOTE_AMOUNT;
		// overloading : )
		if (noteData >= NOTE_AMOUNT * 2 && noteData < NOTE_AMOUNT * 4) {
			mineNote = true;
		}
		if (noteData >= NOTE_AMOUNT * 4 && noteData < NOTE_AMOUNT * 6) {
			isLiftNote = true;
		}
		// die : )
		if (noteData >= NOTE_AMOUNT * 6 && noteData < NOTE_AMOUNT * 8) {
			nukeNote = true;
		}
		if (noteData >= NOTE_AMOUNT * 8 && noteData < NOTE_AMOUNT * 10) {
			drainNote = true;
		}
		if (isLiftNote || mineNote || nukeNote)
			shouldBeSung = false;
		// var daStage:String = PlayState.curStage;
		if (FNFAssets.exists('assets/images/custom_ui/ui_packs/' + PlayState.SONG.uiType + "/NOTE_assets.xml")
			&& FNFAssets.exists('assets/images/custom_ui/ui_packs/' + PlayState.SONG.uiType + "/NOTE_assets.png"))
		{
			frames = FlxAtlasFrames.fromSparrow(customImage, customXml);
			if (animSuffix == null)
			{
				animSuffix = '';
			}
			else
			{
				animSuffix = ' ' + animSuffix;
			}
			animation.addByPrefix('greenScroll', 'green${animSuffix}0');
			animation.addByPrefix('redScroll', 'red${animSuffix}0');
			animation.addByPrefix('blueScroll', 'blue${animSuffix}0');
			animation.addByPrefix('purpleScroll', 'purple${animSuffix}0');

			animation.addByPrefix('purpleholdend', 'pruple end hold${animSuffix}');
			animation.addByPrefix('greenholdend', 'green hold end${animSuffix}');
			animation.addByPrefix('redholdend', 'red hold end${animSuffix}');
			animation.addByPrefix('blueholdend', 'blue hold end${animSuffix}');

			animation.addByPrefix('purplehold', 'purple hold piece${animSuffix}');
			animation.addByPrefix('greenhold', 'green hold piece${animSuffix}');
			animation.addByPrefix('redhold', 'red hold piece${animSuffix}');
			animation.addByPrefix('bluehold', 'blue hold piece${animSuffix}');
			if (isLiftNote)
			{
				animation.addByPrefix('greenScroll', 'green lift${animSuffix}');
				animation.addByPrefix('redScroll', 'red lift${animSuffix}');
				animation.addByPrefix('blueScroll', 'blue lift${animSuffix}');
				animation.addByPrefix('purpleScroll', 'purple lift${animSuffix}');
			}
			if (nukeNote)
			{
				animation.addByPrefix('greenScroll', 'green nuke${animSuffix}');
				animation.addByPrefix('redScroll', 'red nuke${animSuffix}');
				animation.addByPrefix('blueScroll', 'blue nuke${animSuffix}');
				animation.addByPrefix('purpleScroll', 'purple nuke${animSuffix}');
			}
			
			if (mineNote)
			{
				animation.addByPrefix('greenScroll', 'green mine${animSuffix}');
				animation.addByPrefix('redScroll', 'red mine${animSuffix}');
				animation.addByPrefix('blueScroll', 'blue mine${animSuffix}');
				animation.addByPrefix('purpleScroll', 'purple mine${animSuffix}');
			}
			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = true;
			// when arrowsEnds != arrowEnds :laughing_crying:
		}
		else if (FNFAssets.exists('assets/images/custom_ui/ui_packs/' + PlayState.SONG.uiType + "/arrows-pixels.png")
			&& FNFAssets.exists('assets/images/custom_ui/ui_packs/' + PlayState.SONG.uiType + "/arrowEnds.png"))
		{
			isPixel = true;
			loadGraphic(customImage, true, 17, 17);
			if (animSuffix != null && numSuffix == null)
			{
				numSuffix = Std.parseInt(animSuffix);
			}
			if (numSuffix != null)
			{
				var intSuffix = numSuffix;
				animation.add('greenScroll', [intSuffix]);
				animation.add('redScroll', [intSuffix]);
				animation.add('blueScroll', [intSuffix]);
				animation.add('purpleScroll', [intSuffix]);
				if (isSustainNote)
				{
					loadGraphic('assets/images/weeb/pixelUI/arrowEnds.png', true, 7, 6);

					animation.add('purpleholdend', [intSuffix]);
					animation.add('greenholdend', [intSuffix]);
					animation.add('redholdend', [intSuffix]);
					animation.add('blueholdend', [intSuffix]);

					animation.add('purplehold', [intSuffix]);
					animation.add('greenhold', [intSuffix]);
					animation.add('redhold', [intSuffix]);
					animation.add('bluehold', [intSuffix]);
				}
				if (isLiftNote)
				{
					animation.add('greenScroll', [intSuffix]);
					animation.add('redScroll', [intSuffix]);
					animation.add('blueScroll', [intSuffix]);
					animation.add('purpleScroll', [intSuffix]);
				}
			}
			else
			{
				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustainNote)
				{
					loadGraphic('assets/images/weeb/pixelUI/arrowEnds.png', true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}
				if (isLiftNote)
				{
					animation.add('greenScroll', [22]);
					animation.add('redScroll', [23]);
					animation.add('blueScroll', [21]);
					animation.add('purpleScroll', [20]);
				}
			}

			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			updateHitbox();
		}
		else
		{
			// no crashing today :)
			trace(PlayState.SONG.uiType);
			frames = FlxAtlasFrames.fromSparrow('assets/images/NOTE_assets.png', 'assets/images/NOTE_assets.xml');

			animation.addByPrefix('greenScroll', 'green0');
			animation.addByPrefix('redScroll', 'red0');
			animation.addByPrefix('blueScroll', 'blue0');
			animation.addByPrefix('purpleScroll', 'purple0');

			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix('greenholdend', 'green hold end');
			animation.addByPrefix('redholdend', 'red hold end');
			animation.addByPrefix('blueholdend', 'blue hold end');

			animation.addByPrefix('purplehold', 'purple hold piece');
			animation.addByPrefix('greenhold', 'green hold piece');
			animation.addByPrefix('redhold', 'red hold piece');
			animation.addByPrefix('bluehold', 'blue hold piece');

			if (isLiftNote)
			{
				animation.addByPrefix('greenScroll', 'green lift');
				animation.addByPrefix('redScroll', 'red lift');
				animation.addByPrefix('blueScroll', 'blue lift');
				animation.addByPrefix('purpleScroll', 'purple lift');
			}
			if (nukeNote) {
				animation.addByPrefix('greenScroll', 'green nuke');
				animation.addByPrefix('redScroll', 'red nuke');
				animation.addByPrefix('blueScroll', 'blue nuke');
				animation.addByPrefix('purpleScroll', 'purple nuke');
			}
			if (mineNote) {
				animation.addByPrefix('greenScroll', 'green mine');
				animation.addByPrefix('redScroll', 'red mine');
				animation.addByPrefix('blueScroll', 'blue mine');
				animation.addByPrefix('purpleScroll', 'purple mine');
			}
			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = true;
		}
		switch (noteData % NOTE_AMOUNT)
		{
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}

		// trace(prevNote);
		if (isSustainNote && OptionsHandler.options.downscroll) {
			flipY = true;
		}
		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			switch (noteData % NOTE_AMOUNT)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (isPixel)
				x += 30;

			if (prevNote.isSustainNote)
			{
				// DO mod it because we DIDN'T do that
				switch (prevNote.noteData % NOTE_AMOUNT)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		// if we are player one and it's bf's note or we are duo mode or we are player two and it's p2's note
		// and it isn't demo mode
		if ((((mustPress && !oppMode) || duoMode) || (oppMode && !mustPress)) && !funnyMode)
		{
			var signedDiff = Conductor.songPosition - strumTime;
			// ok.... so if strumTime is bigger than songPosition that means it is waiting to be hit because well the song hasn't reached it???
			// negative is early, positive is late
			var noteDiff = Math.abs(signedDiff);
			// The * 0.5 us so that its easier to hit them too late, instead of too early
			if (noteDiff < Judge.wayoffJudge * timingMultiplier)
			{
				canBeHit = true;
			}
			else
				canBeHit = false;
			// Nuke notes can only be hit with a bad or better because nuke notes are weird champ
			if (nukeNote && !(noteDiff < Judge.badJudge * timingMultiplier)) {
				canBeHit = false;
			}
			if (mineNote && !(noteDiff < Judge.shitJudge * timingMultiplier))
			{
				canBeHit = false;
			}
			if (signedDiff > Judge.wayoffJudge)
				tooLate = true;
			if (nukeNote && signedDiff > Judge.badJudge) {
				tooLate = true;
			}
			if (mineNote && signedDiff > Judge.shitJudge) {
				tooLate = true;
			}
		}
		else
		{
			if (!mineNote && !nukeNote) {
				canBeHit = false;

				if (strumTime <= Conductor.songPosition)
				{
					wasGoodHit = true;
				}
			}
			
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
