async function getVideoURI(youtube_url) {
  let url = new URL(youtube_url);
  let vid = url.searchParams.get("v");
  let vid_uri = `http://127.0.0.1:5000/videos/vid/${vid}`;
  let request = new Request(vid_uri);
  let response = await fetch(request);
  if (response.status === 200) return response.headers.get("location");
  if (response.status === 404) {
    let request = new Request(vid_uri, { method: "POST" });
    let response = await fetch(request);
    if (response.status === 201) return response.headers.get("location");
    else return null;
  }
  else return null;
}

async function getVideoWarnings(video_uri) {
  let warnings_uri = `${video_uri}/warnings`;
  let request = new Request(warnings_uri);
  let response = await fetch(request);
  if (response.status === 200) return response.json();
  else return null;
}

async function createWarning(video_uri, start, stop, description) {
  let warning_uri = `${video_uri}/warnings`;
  let request = new Request(warning_uri, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      start: start,
      stop: stop,
      description: description
    }),
  });
  let response = await fetch(request);
  return response;
}



function timeStr(int_seconds) {
  let seconds = int_seconds % 60;
  let int_minutes = Math.floor(int_seconds / 60);
  let hours = Math.floor(int_minutes / 60);
  let minutes = int_minutes % 60;
  if (hours != 0)
    return `${hours}:${String(minutes).padStart(2, "0")}:${seconds}`;
  else return `${String(minutes).padStart(2, "0")}:${seconds}`;
}

let url = "https://www.youtube.com/watch?v=4jXEuIHY9ic";

function setWarningMsg(warnings) {
  let target = document.getElementById("content");

  // TODO: This is aggressively insecure, definitely need to change this later
  target.innerHTML = "";
  warnings.forEach(w => {
    target.innerHTML += `
    <p>
    <hr>
    <b>Time</b>: ${timeStr(w.warning_start)} - ${timeStr(w.warning_end)}<br>
    <b>Description</b>: ${w.warning_description}<br>
    </p>
    `;
  });
}

window.onload = () => {
  document.getElementById("warnings").onclick = () => {
    chrome.tabs.query({ active: true, lastFocusedWindow: true }, tabs => {
      let url = tabs[0].url;

      (async () => {
        let uri = await getVideoURI(url);
        let warnings = await getVideoWarnings(uri);
        return warnings;
      })().then(warnings => {
        setWarningMsg(warnings);
      });
    });
  };

  document.getElementById("create-warning").onclick = () => {
    chrome.tabs.query({ active: true, lastFocusedWindow: true }, tabs => {
      // let url = tabs[0].url;
      let target = document.getElementById("content");
      target.innerHTML = `
      <form id="warning-form">
        <label for="start">Warning start time:</label><br>
        <input type="number" step="1" min="0" id="start" name="start"><br>
        <label for="stop">Warning stop time:</label><br>
        <input type="number" step="1" min="0" id="stop" name="stop"><br>
        <label for="Description">Warning description:</label><br>
        <input type="text" id="description" name="description"><br>
        <input type="submit" value="Submit">
      </form>
        `;

      const form = document.getElementById("warning-form");
      form.addEventListener("submit", submit => {
        let start = form.start.value;
        let stop = form.stop.value;
        let description = form.description.value;
        let prom = (async () => {
            let uri = await getVideoURI(url);
            return createWarning(uri, start, stop, description);
        })();
        // prom.then(() => {
        //   let target = document.getElementById("content");
        //   target.innerHTML = "Warning Created"
        // });
      });

    });
  };
};
