package;

import openfl.display.Sprite;
import openfl.events.Event;

/**
 * Entry point for Xiao Xiao 4 recreation.
 * Mirrors the original Flash 5 root timeline structure.
 *
 * Original game architecture (from decompiled AS1):
 * - Preloader → Menu screen → Gameplay (rail shooter) → Game Over
 * - 18 FPS, 550x400 stage, black background
 * - Input: mouse position for crosshair, mouse click to shoot
 */
class Main extends Sprite {
    public function new() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event):Void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        // TODO: Initialize game state machine
        // Phase 1: Load and verify original assets
        // Phase 2: Implement frame-based state machine
        // Phase 3: Port AS1 game logic to Haxe
        trace("Xiao Xiao 4 Recreation — Initializing...");
    }
}
