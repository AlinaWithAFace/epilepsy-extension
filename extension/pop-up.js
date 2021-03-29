// TODO: Make sure there is json for the request
async function getMessage(url) {
  let request = new Request("http://127.0.0.1:5000/screen-video", {
    method: "POST",
    body: JSON.stringify({
      url: url
    }),
    headers: {
      "Content-type": "application/json; charset=UTF-8"
    }
  });
  let response = (await fetch(request));
  if (response.status === 201) {
    return (await response.json()).message;
  } else {
    return (await response.json()).error;
  }
}

// TODO: replace the alert with a better UI
window.onload = () => {
  document.getElementById("screen-video").onclick = () => {
    chrome.tabs.query({active: true, lastFocusedWindow: true}, tabs => {
      let url = tabs[0].url;
      getMessage(url).then(r => alert(r));
    });
  };
};
