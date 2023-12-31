// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

const confetti = window.confetti;

Hooks = {};

Hooks.CopyToClipboard = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      const result = document.getElementById("scoreboard");

      console.log(result);

      navigator.clipboard.writeText(result.innerText);

      Toastify({
        text: "Copied Scoreboard to clipboard",
        duration: 1000,
        newWindow: true,
        close: false,
        gravity: "top", // `top` or `bottom`
        position: "right", // `left`, `center` or `right`
        stopOnFocus: true, // Prevents dismissing of toast on hover
        className: "font-fight",
        shadowColor: "none",
        onClick: function () {}, // Callback after click
      }).showToast();
    });
  },
};

Hooks.CopyLinkToClipboard = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      const url = window.location.href.split("/").slice(0, 5).join("/");

      navigator.clipboard.writeText(url);

      Toastify({
        text: "Copied link to clipboard",
        duration: 1000,
        newWindow: true,
        close: false,
        gravity: "top", // `top` or `bottom`
        position: "right", // `left`, `center` or `right`
        stopOnFocus: true, // Prevents dismissing of toast on hover
        className: "font-fight",
        shadowColor: "none",
        onClick: function () {}, // Callback after click
      }).showToast();
    });
  },
};

Hooks.Bell = {
  mounted() {
    this.handleEvent("ring", ({ sounds }) => {
      if (sounds) {
        console.log("bell");
        let audio = new Audio("/sounds/bell-start.mp3");
        audio.play();
      }
    });
  },
};

Hooks.Timer = {
  mounted() {
    this.handleEvent("scrollTop", ({}) => {
      window.scrollTo(0, 0);
    });
    this.handleEvent("timer", ({ game_over }) => {
      const timerElement = document.getElementById("timer");
      // 5 second countdown
      let count = 5;

      let interval = setInterval(() => {
        count -= 1;

        timerElement.innerText = `${count}`;

        if (count <= 0) {
          clearInterval(interval);
          this.pushEvent("next", {});
        }
      }, 1000); // update every 1s for 3 seconds

      // Save interval id to the socket for later use
      this.el.dataset.intervalId = interval;
    });
    this.handleEvent("clear_interval", (_payload) => {
      const intervalId = this.el.dataset.intervalId;
      if (intervalId) {
        clearInterval(intervalId);
      }
    });
  },
};

Hooks.Confetti = {
  mounted() {
    this.handleEvent("confetti", ({ winner, sounds }) => {
      if (sounds) {
        console.log(`winner is ${winner}`);
        if (winner.includes("gpt")) {
          let robotNum = Math.floor(Math.random() * 4) + 1;
          let robotAudio = new Audio(`/sounds/robot${robotNum}.mp3`);
          robotAudio.play();
        } else if (winner.includes("llama")) {
          let llamaNum = Math.floor(Math.random() * 2) + 1;
          let llamaAudio = new Audio(`/sounds/llama${llamaNum}.mp3`);
          llamaAudio.play();
        } else if (winner.includes("sdxl")) {
          let sdxlNum = Math.floor(Math.random() * 3) + 1;
          let sdxlAudio = new Audio(`/sounds/sdxl${sdxlNum}.mp3`);
          sdxlAudio.play();
        } else if (winner.includes("kandinsky")) {
          let kandinskyNum = Math.floor(Math.random() * 3) + 1;
          let kandinskyAudio = new Audio(
            `/sounds/kandinsky${kandinskyNum}.mp3`
          );
          kandinskyAudio.play();
        } else if (winner.includes("midjourney")) {
          let midjourneyNum = Math.floor(Math.random() * 3) + 1;
          let midjourneyAudio = new Audio(
            `/sounds/midjourney${midjourneyNum}.mp3`
          );
          midjourneyAudio.play();
        }

        let punchNum = Math.floor(Math.random() * 5) + 1;
        let audio = new Audio(`/sounds/punch${punchNum}.mp3`);
        audio.play();
      }

      confetti({
        particleCount: 100,
        spread: 70,
        origin: { y: 0.6 },
      });
    });
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
