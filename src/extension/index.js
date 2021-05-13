window.onload = () => {
  var app = Elm.Main.init({
    node: document.getElementById("myapp"),
    flags: "https://www.youtube.com/watch?v=QRZqC1tr9KE"
  });
};
// window.onload = () => {
//   chrome.tabs.query({ active: true, lastFocusedWindow: true }, tabs => {
//     var app = Elm.Main.init({
//       node: document.getElementById("myapp"),
//       flags: tabs[0].url
//     });
//   });
// };
