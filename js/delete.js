// Remove the delete button on the footer of issues pages
function removeDelete() {
  try {
    // Check that we're in the right path
    const match = window.location.pathname.match(/^\/issues\/([0-9]*)$/);
    if (match && match.length === 2) {
      $("div#content div.contextual a.icon.icon-del").detach();
    }
  } catch (e) {
    console.warn("Failed in delete");
    console.warn(e);
  }
}

$(document).ready(removeDelete);
