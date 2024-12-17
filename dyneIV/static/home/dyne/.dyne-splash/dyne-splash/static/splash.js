/*
Copyright Lorenzo L. Ancora - 2024.
Licensed under the European Union Public License 1.2
SPDX-License-Identifier: EUPL-1.2
Created for the Dynebolic project.
*/
"use strict";
function isFullscreen() {
    return window.innerHeight === screen.height || window.innerHeight === screen.availHeight;
}
function updfsswitch(e) {
    function syncswitchstate() {
        var documentisfs = isFullscreen();
        var UIswitch = e.data.cb;
        UIswitch.prop('checked', documentisfs);
    }
    requestIdleCallback(syncswitchstate, { 'timeout': 500 });
}
function gofs() {
    document.documentElement.requestFullscreen().catch(function (err) {
        alert("Error attempting to enable fullscreen mode: ".concat(err.message, " (").concat(err.name, ")"));
    });
}
function quitfs() {
    document.exitFullscreen();
}
function reqfs(e) {
    var UIswitch = e.data.cb;
    if (UIswitch.prop('checked') == true)
        gofs();
    else
        quitfs();
}
$(function () {
    var fullscreenSwitch = $("#fsswitch");
    $(document).on("fullscreenchange resize load", { "cb": fullscreenSwitch }, updfsswitch);
    setInterval(updfsswitch, 500, { "data": { 'cb': fullscreenSwitch } });
    fullscreenSwitch.on("click", { "cb": fullscreenSwitch }, reqfs);
    function savefschoiche() {
        sessionStorage.setItem("fschoichedone", String(true));
        console.log("Fullscreen decision saved: fschoichedone := ".concat(sessionStorage.getItem("fschoichedone")));
    }
    var sQuery = new URLSearchParams(window.location.search);
    var choicedone = Boolean(sessionStorage.getItem("fschoichedone"));
    if (sQuery.has('fs') && choicedone !== true) {
        var jmodal = $('#staticBackdropModal');
        var modal_1 = new bootstrap.Modal(jmodal[0]);
        $("#fsmbtn").on("click", gofs);
        setInterval(function () { try {
            modal_1("handleUpdate");
        }
        catch (_a) { } }, 350);
        jmodal.on('hidden.bs.modal', savefschoiche);
        modal_1.show();
    }
});
//# sourceMappingURL=splash.js.map