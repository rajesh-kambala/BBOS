function bbAlert(msg, header) {
  msg = msg.replace(/\n/g, "<br />");
  bootbox.alert({ title: header, message: msg });
}

function bbConfirm(sender, msg) {
  if ($(sender).attr("confirmed") == "true") { return true; }

  bootbox.confirm(msg, function (confirmed) {
    if (confirmed) {
      $(sender).attr("confirmed", confirmed).trigger("click");
    }
  });

  return false;
}

function bbConfirmWithOption(sender, msg, optionMsg, optionHidden) {

  if ($(sender).attr("confirmed") == "true") { return true; }

  bootbox.prompt({
    title: msg,
    inputType: 'checkbox',
    inputOptions: [
        {
          text: optionMsg,
          value: 'true',
        }
    ],
    callback: function (result) {

      if (result == null) {
        return;  // The user cancelled.
      }

      if (result.length > 0) {
        optionHidden.value = result[0];
      }
      $(sender).attr("confirmed", true).trigger("click");
    }
  });

  return false;
}

function bbApproveDeny(sender, msg, optionHidden) {
  if ($(sender).attr("approved") == "approved" || $(sender).attr("approved") == "denied") { return true; }

  bootbox.dialog({
      message: "Debe aprobar el siguiente cambio.<br/><br/>" + msg,
      title: "Se Requiere Aprobación",
    buttons: {
      success: {
          label: "Aprobado",
        className: "btn-success",
        callback: function (result) {
          if (result == null)
            return; // The user cancelled.

          optionHidden.value = "approved";
          $(sender).attr("approved", "approved").trigger("click");
        }
      },
      danger: {
          label: "Denegado",
        className: "btn-danger",
        callback: function (result) {
          if (result == null)
            return; // The user cancelled.
          optionHidden.value = "denied";
          $(sender).attr("approved", "denied").trigger("click");
        }
      },
      main: {
          label: "Cancelar",
        className: "btn-primary",
        callback: function (result) {
          return; // The user cancelled.
        }
      }
    }
  });

  return false;
}

  function bbAllJustThisCancel(sender, msg, optionHidden) {
    if ($(sender).attr("approved") == "all" || $(sender).attr("approved") == "one") { return true; }

    bootbox.dialog({
      message: msg,
      title: "Borrar Confirmación",
      buttons: {
        success: {
            label: "Todo",
          className: "btn-success",
          callback: function (result) {
            if (result == null)
              return; // The user cancelled.

            optionHidden.value = "all";
            $(sender).attr("approved", "all").trigger("click");
          }
        },
        danger: {
            label: "Solo Esto",
          className: "btn-success",
          callback: function (result) {
            if (result == null)
              return; // The user cancelled.
            optionHidden.value = "one";
            $(sender).attr("approved", "one").trigger("click");
          }
        },
        main: {
            label: "Cancelar",
          className: "btn-primary",
          callback: function (result) {
            return; // The user cancelled.
          }
        }
      }
    });

  return false;
}