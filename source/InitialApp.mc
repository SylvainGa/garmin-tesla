using Toybox.Application as App;
using Toybox.Background;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi as Ui;

(:background)
class QuickTesla extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getServiceDelegate(){
        return [ new MyServiceDelegate() ];
    }

    // This fires when the background service returns
    function onBackgroundData(data) {
        Application.getApp().setProperty("status", data["status"]);
        logMessage("onBackgroundData: " + data["status"]);
        Ui.requestUpdate();
    }  

    (:glance)
    function getGlanceView() {
        return [ new GlanceView() ];
    }

    function getInitialView() {
        Background.registerForTemporalEvent(new Time.Duration(60*5));

        // No phone? This widget ain't gonna work! Show the offline view
        if (!System.getDeviceSettings().phoneConnected) {
            return [ new OfflineView() ];
        }

        var data = new TeslaData();
        var view = new MainView(data);

        return [ view, new MainDelegate(data, view.method(:onReceive)) ];
    }

    (:debug)
    function logMessage(message) {
        System.println(message);
    }

    (:release)
    function logMessage(message) {
        
    }
}