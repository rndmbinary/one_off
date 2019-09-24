//For Browser Consoles Only

javascript: document.getElementsByTagName("body")[0].innerHTML = "<iframe id=\"refreshFrame\" src=\""
    + window.location.toString() + "\" style=\"position: absolute; top:0; left:0; right:0; bottom:0; width:100%; height:100%;\">" 
    + "<\/iframe>";

reloadTimer = setInterval(function () {
    document.getElementById("refreshFrame").src = document.getElementById("refreshFrame").src
}, 180000)
