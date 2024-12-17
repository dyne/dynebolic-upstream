/*
Copyright Lorenzo L. Ancora - 2024.
Licensed under the European Union Public License 1.2
SPDX-License-Identifier: EUPL-1.2
Created for the Dynebolic project.
*/
"use strict";

declare var bootstrap: any;

function isFullscreen(): boolean {
    return window.innerHeight === screen.height || window.innerHeight === screen.availHeight;
}


function updfsswitch(e: JQuery.TriggeredEvent): void {
     function syncswitchstate(): void {
        let documentisfs: boolean = isFullscreen();
        let UIswitch: JQuery<HTMLInputElement> = e.data.cb;

        UIswitch.prop('checked', documentisfs);
    }
    requestIdleCallback(syncswitchstate, {'timeout':500});
}

function gofs(): void {
    document.documentElement.requestFullscreen().catch((err) => {
        alert(
        `Error attempting to enable fullscreen mode: ${err.message} (${err.name})`,
        );
    });
}

function quitfs(): void {
    document.exitFullscreen();
}

function reqfs(e: JQuery.ClickEvent): void {
    let UIswitch: JQuery<HTMLInputElement> = e.data.cb;

    if (UIswitch.prop('checked') == true) gofs();
    else quitfs();
}


$(function(){
    let fullscreenSwitch: JQuery<HTMLInputElement> = $("#fsswitch");
    
    $(document).on("fullscreenchange resize load", {"cb": fullscreenSwitch}, updfsswitch);
    setInterval(updfsswitch, 500, {"data":{'cb': fullscreenSwitch}});
    fullscreenSwitch.on("click", {"cb": fullscreenSwitch}, reqfs);

    function savefschoiche() {
        sessionStorage.setItem("fschoichedone", String(true));
        console.log(`Fullscreen decision saved: fschoichedone := ${sessionStorage.getItem("fschoichedone")}`);
    }

    let sQuery = new URLSearchParams(window.location.search);
    let choicedone: boolean = Boolean(sessionStorage.getItem("fschoichedone"));
    if (sQuery.has('fs') && choicedone !== true) {
        let jmodal: JQuery<HTMLElement> = $('#staticBackdropModal');
        const modal = new bootstrap.Modal(jmodal[0]);
        $("#fsmbtn").on("click", gofs);
        setInterval(()=>{try{modal("handleUpdate");} catch {}}, 350);
        jmodal.on('hidden.bs.modal', savefschoiche);
        modal.show();
    }
});