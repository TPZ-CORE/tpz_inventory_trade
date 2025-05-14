
/*-----------------------------------------------------------
 Functions
-----------------------------------------------------------*/

function closeUI() {
  toggleUI(false);

  $(".inventory_transaction").fadeOut();
  $(".in-progress-create").fadeOut();

  $("#in-progress-create-cost-input").val(0);

  CURRENT_SELECTED_ACCOUNT_TYPE = 0;

	$.post('http://tpz_inventory_trade/close', JSON.stringify({}));
}

function toggleUI(bool) {

  bool ? $("#main").fadeIn() :$("#main").fadeOut();
}

/*-----------------------------------------------------------
  General Action
-----------------------------------------------------------*/

$(function() {

	window.addEventListener('message', function(event) {
		
    let item = event.data;

    if (item.action === 'toggle') {

      document.body.style.display = item.toggle ? "block" : "none";

			toggleUI(item.toggle);

    } else if (event.data.action == "startTradingTransactionProcess") {

      $('body').css({height: '15vw'});

      $("#in-progress-create-quantity-input").val(item.item_quantity);

      $("#in-progress-create-title").text(item.title);
      $("#in-progress-create-quantity-description").text(item.quantity_description);
      $("#in-progress-create-cost-description").text(item.cost_description);

      MAXIMUM_QUANTITY              = item.item_quantity;
      CURRENT_SELECTED_ACCOUNT_TYPE = 0;

      $("#in-progress-create-quantity-input").prop("readonly", item.isReadable); // sets it as readonly if quantity == 1 or is weapon type.
        
      $("#in-progress-create-account-current").text(Locales[0]);

      $(".on-target-progress").fadeOut();
      $(".in-progress-create").fadeIn();

    } else if (event.data.action == "onInventoryGiveTransactionAwaiting") {
      let prod_data = event.data.item_data;
      let prod_username = event.data.sender_username;

      $('body').css({height: '12vw'});

      $(".in-progress-create").fadeOut();
      $(".on-target-progress").fadeIn();
  
      document.getElementById("on-target-progress-image-display").src = getItemIMG(prod_data.item);

      $("#on-target-progress-sender-username").text(prod_username);

      $("#on-target-progress-cost").text(event.data.cost_display);

      $("#on-target-progress-image-amount-display").text(event.data.count);
      $("#on-target-progress-image-name-display").text(prod_data.label);

      (prod_data.itemId != null && prod_data.itemId != 0 && prod_data.durability != null && prod_data.durability > 0) ? $("#on-target-progress-image-durability-display").show() : $("#on-target-progress-image-durability-display").hide();

      $("#on-target-progress-image-durability-display").text(prod_data.durability + "%");

    } else if (event.data.action == "close") {
      closeUI();
    }

  });

  /*-----------------------------------------------------------
  Button Actions
  -----------------------------------------------------------*/

  $("#main").on("click", "#in-progress-create-accept", function() {
    playAudio("button_click.wav");

    let $Quantity = document.getElementById("in-progress-create-quantity-input").value;
    let $Cost = document.getElementById("in-progress-create-cost-input").value;

    $.post("http://tpz_inventory_trade/startTradingProcess", JSON.stringify({
      quantity : $Quantity,
      cost : $Cost,
      account : CURRENT_SELECTED_ACCOUNT_TYPE
    }));

  });

  $("#main").on("click", "#in-progress-create-cancel", function() {
    playAudio("button_click.wav");

    $.post("http://tpz_inventory_trade/cancelTradingProcess", JSON.stringify({}));

  });

  $("#main").on("click", "#on-target-progress-accept", function() {
    playAudio("button_click.wav");

    $.post("http://tpz_inventory_trade/accept", JSON.stringify({}));
  });


  $("#main").on("click", "#on-target-progress-decline", function() {
    playAudio("button_click.wav");

    $.post("http://tpz_inventory_trade/decline", JSON.stringify({}));
  });


  /*-----------------------------------------------------------
  Account Selection Button Actions
  -----------------------------------------------------------*/

  $("#main").on("click", "#in-progress-create-account-previous", function() {
    playAudio("button_click.wav");

    CURRENT_SELECTED_ACCOUNT_TYPE--;

    if (CURRENT_SELECTED_ACCOUNT_TYPE <= 0){
      CURRENT_SELECTED_ACCOUNT_TYPE = 0;
    }

    $("#in-progress-create-account-current").text(Locales[CURRENT_SELECTED_ACCOUNT_TYPE]);

  });


  $("#main").on("click", "#in-progress-create-account-next", function() {
    playAudio("button_click.wav");

    CURRENT_SELECTED_ACCOUNT_TYPE++;

    if (CURRENT_SELECTED_ACCOUNT_TYPE >= MAXIMUM_ACCOUNT_TYPES){
      CURRENT_SELECTED_ACCOUNT_TYPE = MAXIMUM_ACCOUNT_TYPES;
    }

    $("#in-progress-create-account-current").text(Locales[CURRENT_SELECTED_ACCOUNT_TYPE]);
  });



});