window.onload = () => {
  chrome.tabs.query({ active: true, lastFocusedWindow: true }, tabs => {
    var app = Elm.Main.init({
      node: document.getElementById("myapp"),
      flags: tabs[0].url
    });
  });
};
