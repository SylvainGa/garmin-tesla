using Toybox.WatchUi as Ui;
using Toybox.Graphics;

class MediaControlDelegate extends Ui.BehaviorDelegate {
    var _view;
    var _controller;
    var _useTouch;
    var _previous_stateMachineCounter;
    var _fontHeight;
    var _handler;

    function initialize(view, controller, previous_stateMachineCounter, handler) {
        BehaviorDelegate.initialize();
        _view = view;
        _controller = controller;
        _previous_stateMachineCounter = previous_stateMachineCounter;
        _handler = handler;

        _controller._stateMachineCounter = 1; // Make sure our vehicle data is fresh
        _useTouch = controller._useTouch;

        _fontHeight = Graphics.getFontHeight(Graphics.FONT_TINY);
    }

    function onSelect() {
		if (_useTouch) {
			return false;
		}

        if (_view._showVolume) {
            //DEBUG 2023-10-02*/ logMessage("MediaControlDelegate:onSelect volume up");
            //_controller._pendingActionRequests.add({"Action" => ACTION_TYPE_MEDIA_CONTROL, "Option" => ACTION_OPTION_MEDIA_VOLUME_UP, "Value" => 0, "Tick" => System.getTimer()});
            _controller._tesla.mediaVolumeUp(_controller._vehicle_id, method(:onCommandReturn));
        }
        else {
            //DEBUG 2023-10-02*/ logMessage("MediaControlDelegate:onSelect next song");
            //_controller._pendingActionRequests.add({"Action" => ACTION_TYPE_MEDIA_CONTROL, "Option" => ACTION_OPTION_MEDIA_NEXT_SONG, "Value" => 0, "Tick" => System.getTimer()});
            _controller._tesla.mediaNextTrack(_controller._vehicle_id, method(:onCommandReturn));
        }
        return true;
    }

    function onNextPage() {
		if (_useTouch) {
			return false;
		}

        //DEBUG 2023-10-02*/ logMessage("MediaControlDelegate:onPrevPage Play toggle");
        //_controller._pendingActionRequests.add({"Action" => ACTION_TYPE_MEDIA_CONTROL, "Option" => ACTION_OPTION_MEDIA_PLAY_TOGGLE, "Value" => 0, "Tick" => System.getTimer()});
        _controller._tesla.mediaTogglePlayback(_controller._vehicle_id, method(:onCommandReturn));
        return true;
    }

    function onPreviousPage() {
		if (_useTouch) {
			return false;
		}

        if (_view._showVolume) {
            //DEBUG 2023-10-02*/ logMessage("MediaControlDelegate:onNextPage volume down");
            //_controller._pendingActionRequests.add({"Action" => ACTION_TYPE_MEDIA_CONTROL, "Option" => ACTION_OPTION_MEDIA_VOLUME_DOWN, "Value" => 0, "Tick" => System.getTimer()});
            _controller._tesla.mediaVolumeDown(_controller._vehicle_id, method(:onCommandReturn));
        }
        else {
            //DEBUG 2023-10-02*/ logMessage("MediaControlDelegate:onNextPage previous song");
            //_controller._pendingActionRequests.add({"Action" => ACTION_TYPE_MEDIA_CONTROL, "Option" => ACTION_OPTION_MEDIA_PREV_SONG, "Value" => 0, "Tick" => System.getTimer()});
            _controller._tesla.mediaPrevTrack(_controller._vehicle_id, method(:onCommandReturn));
        }
        return true;
    }

    function onMenu() {
		if (_useTouch) {
			return false;
		}

        _view._showVolume = (_view._showVolume == false);
        Ui.requestUpdate();
        return true;
    }

    function onBack() {
        // Unless we missed data, restore _stateMachineCounter
        _controller._stateMachineCounter = (_controller._stateMachineCounter != -2 ? _previous_stateMachineCounter : 1);
        //DEBUG 2023-10-02*/ logMessage("MediaControlDelegate:onBack, returning _stateMachineCounter to " + _controller._stateMachineCounter);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

	function onTap(click) {
        var bm = Ui.loadResource(Rez.Drawables.prev_song_icon); // All icon are the same size, use this one to get the size so we can position it on screen
        var bm_width = bm.getWidth();
        var bm_height = bm.getHeight();
        var width = System.getDeviceSettings().screenWidth;
        var height = System.getDeviceSettings().screenHeight;

		var coords = click.getCoordinates();
		var x = coords[0];
		var y = coords[1];

        // Center of screen where play button is
        if (x > width / 2 - bm_width / 2 && x < width / 2 + bm_width / 2 && y > height / 2 - bm_height / 2 + _fontHeight - height / 20 && y < height / 2 + bm_height / 2 + _fontHeight - height / 20) {
            //DEBUG 2023-10-02*/ logMessage("MediaControlDelegate:onTap Play toggle");
            //_controller._pendingActionRequests.add({"Action" => ACTION_TYPE_MEDIA_CONTROL, "Option" => ACTION_OPTION_MEDIA_PLAY_TOGGLE, "Value" => 0, "Tick" => System.getTimer()});
            _controller._tesla.mediaTogglePlayback(_controller._vehicle_id, method(:onCommandReturn));
        }
        // Left size
        else if (x < width / 2) {
            // Top left
            if (y < height / 2 + _fontHeight - height / 20) {
                //DEBUG 2023-10-02*/ logMessage("MediaControlDelegate:onTap previous song");
                //_controller._pendingActionRequests.add({"Action" => ACTION_TYPE_MEDIA_CONTROL, "Option" => ACTION_OPTION_MEDIA_PREV_SONG, "Value" => 0, "Tick" => System.getTimer()});
                _controller._tesla.mediaPrevTrack(_controller._vehicle_id, method(:onCommandReturn));
             }
            // Bottom left
            else {
                //DEBUG 2023-10-02*/ logMessage("MediaControlDelegate:onTap volume down");
                //_controller._pendingActionRequests.add({"Action" => ACTION_TYPE_MEDIA_CONTROL, "Option" => ACTION_OPTION_MEDIA_VOLUME_DOWN, "Value" => 0, "Tick" => System.getTimer()});
                _controller._tesla.mediaVolumeDown(_controller._vehicle_id, method(:onCommandReturn));
            }
        }
        // Top right
        else if (y < height / 2 + _fontHeight - height / 20) {
            //DEBUG 2023-10-02*/ logMessage("MediaControlDelegate:onTap next song");
            //_controller._pendingActionRequests.add({"Action" => ACTION_TYPE_MEDIA_CONTROL, "Option" => ACTION_OPTION_MEDIA_NEXT_SONG, "Value" => 0, "Tick" => System.getTimer()});
            _controller._tesla.mediaNextTrack(_controller._vehicle_id, method(:onCommandReturn));
        }
        // Bottom right
        else {
            //DEBUG 2023-10-02*/ logMessage("MediaControlDelegate:onTap volume up");
            //_controller._pendingActionRequests.add({"Action" => ACTION_TYPE_MEDIA_CONTROL, "Option" => ACTION_OPTION_MEDIA_VOLUME_UP, "Value" => 0, "Tick" => System.getTimer()});
            _controller._tesla.mediaVolumeUp(_controller._vehicle_id, method(:onCommandReturn));
        }

        Ui.requestUpdate();
        return true;
    }

	function onCommandReturn(responseCode, data) {
        //DEBUG 2023-10-02*/ logMessage("onCommandReturn: " + responseCode);
        // Feedback for the user
		if (Attention has :vibrate) {
			var vibeData = [ new Attention.VibeProfile(50, 200) ]; // On for half a second
			Attention.vibrate(vibeData);				
		}

		if (responseCode == 200) {
            _controller._stateMachineCounter = 5; // Get new vehicle data after 0.5sec so it has time to process it
        }
        else {
            _controller._stateMachineCounter = 20; // Next query event in two seconds
			_handler.invoke(responseCode);
		}
	}
}
