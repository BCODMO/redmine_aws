// Custom injected JS to add osprey info
function addOspreyInfo() {
  // Check that we're in the right path
  const match = window.location.pathname.match(/^\/issues\/([0-9]*)$/);
  if (match.length === 2) {
    const issueId = match[1];
    $("div#content div.attributes")
      .first()
      .append('<div id="bcodmo-osprey-query"></div>');

    fetch(
      `https://private.bco-dmo.org/sparql?default-graph-uri=&query=SELECT+DISTINCT+%3Furi+IF%28STRLEN%28%3Ftitle%29+%3E+0%2C+%3Ftitle%2C+%3Fshort_title%29+as+%3Flabel%0D%0AWHERE+%7B%0D%0A++%0D%0A++GRAPH+%3Chttps%3A%2F%2Fd2rq.bco-dmo.org%2Fid%2Fredmine%2F%3E+%7B+%0D%0A++++%3Furi+odo%3AtrackingIssue+%3Fissue+.%0D%0A++++%3Fissue+odo%3AidentifierValue+%22${issueId}%22%5E%5Exsd%3Atoken+.%0D%0A++++%3Fissue+odo%3AidentifierScheme+odo%3AIdentifierScheme_RedmineIssueTracker+.%0D%0A++%7D%0D%0A++%7B%0D%0A++++SERVICE+%3Chttps%3A%2F%2Flod.bco-dmo.org%2Fsparql%3E+%7B%0D%0A++++++%7B%0D%0A++++++++%3Furi+a+odo%3ADataset+.%0D%0A++++++++OPTIONAL+%7B%3Furi+odo%3AdatasetTitle+%3Ftitle+.%7D%0D%0A++++++++%3Furi+dcterms%3Atitle+%3Fshort_title+.%0D%0A++++++%7D+%0D%0A++++++UNION+%0D%0A++++++%7B%0D%0A++++++++%3Furi+a+odo%3AProject+.%0D%0A++++++++%3Furi+dcterms%3Atitle+%3Ftitle+.%0D%0A++++++++OPTIONAL+%7B%3Furi+odo%3AhasAcronym+%3Fshort_title+.%7D%0D%0A++++++%7D%0D%0A++++%7D%0D%0A++%7D%0D%0A%7D&should-sponge=&format=application%2Fsparql-results%2Bjson&timeout=0&debug=on`
    ).then(async (response) => {
      const data = await response.json();
      for (let key in data.results.bindings) {
        // Make sure the results look like we expect
        if (
          "uri" in data.results.bindings[key] &&
          "label" in data.results.bindings[key]
        ) {
          newEl = $(`
            <div>
              <hr/><strong>OSPREY:</strong> <a
                href="${data.results.bindings[key].uri.value}"
                target="_blank">
                ${data.results.bindings[key].label.value}
              </a>
            </div>

          `);
          $("#bcodmo-osprey-query").append(newEl);
        }
      }
    });
  }
}

$(document).ready(addOspreyInfo);
