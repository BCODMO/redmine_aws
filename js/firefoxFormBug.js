// Fix Firefox form bug that is settings Priority to the wrong value after "Submission Accepted" becomes the State
// https://stackoverflow.com/questions/4831848/firefox-ignores-option-selected-selected
$(document).ready(function () {
  if ("issue-form" in document.forms) {
    document.forms["issue-form"].reset();
  }
});
