
let MAXIMUM_ACCOUNT_TYPES = 1;
let CURRENT_SELECTED_ACCOUNT_TYPE = 0;
let MAXIMUM_QUANTITY = 0

function playAudio(sound) {
	var audio = new Audio('./audio/' + sound);
	audio.volume = Config.DefaultClickSoundVolume;
	audio.play();
}

const loadScript = (FILE_URL, async = true, type = "text/javascript") => {
  return new Promise((resolve, reject) => {
      try {
          const scriptEle = document.createElement("script");
          scriptEle.type = type;
          scriptEle.async = async;
          scriptEle.src =FILE_URL;

          scriptEle.addEventListener("load", (ev) => {
              resolve({ status: true });
          });

          scriptEle.addEventListener("error", (ev) => {
              reject({
                  status: false,
                  message: `Failed to load the script ${FILE_URL}`
              });
          });

          document.body.appendChild(scriptEle);
      } catch (error) {
          reject(error);
      }
  });
};

loadScript("js/locales/locales-" + Config.Locale + ".js").then( data  => { 

  $("#main").hide();

  displayPage("on-target-progress", "visible");
  $(".on-target-progress").fadeOut();

  displayPage("in-progress-create", "visible");
  $(".in-progress-create").fadeOut();

  $("#in-progress-create-accept").text(Locales.AcceptButton);
  $("#in-progress-create-cancel").text(Locales.DeclineButton);

  $("#on-target-progress-accept").text(Locales.AcceptButton);
  $("#on-target-progress-decline").text(Locales.DeclineButton);

  $("#in-progress-create-cost-input").val(0);

}) .catch( err => { console.error(err); });

function displayPage(page, cb){
  document.getElementsByClassName(page)[0].style.visibility = cb;

  [].forEach.call(document.querySelectorAll('.' + page), function (el) {
    el.style.visibility = cb;
  });
}

function load(src) {
  return new Promise((resolve, reject) => {
      const image = new Image();
      image.addEventListener('load', resolve);
      image.addEventListener('error', reject);
      image.src = src;
  });
}

function onNumbers(evt){
  // Only ASCII character in that range allowed
  var ASCIICode = (evt.which) ? evt.which : evt.keyCode;
  
  if (ASCIICode > 31 && (ASCIICode < 48 || ASCIICode > 57))
      return false;
  return true;
}

function getItemIMG(item){
  return 'nui://tpz_inventory/html/img/items/' + item + '.png';
}