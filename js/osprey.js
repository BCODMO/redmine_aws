// Custom injected JS to add osprey info
function addOspreyInfo() {
  try {
    // Check that we're in the right path
    const match = window.location.pathname.match(/^\/issues\/([0-9]*)$/);
    if (match && match.length === 2) {
      const issueId = match[1];
      // Make the request
      fetch(
        `https://private.bco-dmo.org/sparql?default-graph-uri=&query=SELECT+DISTINCT+%3Furi+STR%28%3Fshort_title%29+as+%3Fshort_title+IF%28STRLEN%28%3Ftitle%29+%3E+0%2C+STR%28%3Ftitle%29%2C+%22%22%29+as+%3Ftitle%0D%0AWHERE+%7B%0D%0A++%0D%0A++GRAPH+%3Chttps%3A%2F%2Fd2rq.bco-dmo.org%2Fid%2Fredmine%2F%3E+%7B+%0D%0A++++%3Furi+odo%3AtrackingIssue+%3Fissue+.%0D%0A++++%3Fissue+odo%3AidentifierValue+%22${issueId}%22%5E%5Exsd%3Atoken+.%0D%0A++++%3Fissue+odo%3AidentifierScheme+odo%3AIdentifierScheme_RedmineIssueTracker+.%0D%0A++%7D%0D%0A%7B%0D%0A++++SERVICE+%3Chttps%3A%2F%2Flod.bco-dmo.org%2Fsparql%3E+%7B%0D%0A++++++%7B%0D%0A++++++++%3Furi+a+odo%3ADataset+.%0D%0A++++++++OPTIONAL+%7B%3Furi+odo%3AdatasetTitle+%3Ftitle+.%7D%0D%0A++++++++%3Furi+dcterms%3Atitle+%3Fshort_title+.%0D%0A++++++%7D+%0D%0A++++++UNION+%0D%0A++++++%7B%0D%0A++++++++%3Furi+a+odo%3AProject+.%0D%0A++++++++%3Furi+dcterms%3Atitle+%3Ftitle+.%0D%0A++++++++OPTIONAL+%7B%3Furi+odo%3AhasAcronym+%3Fshort_title+.%7D%0D%0A++++++%7D%0D%0A++++%7D%0D%0A++%7D%0D%0A%7D&should-sponge=&format=application%2Fsparql-results%2Bjson&timeout=0&debug=on`
      ).then(async (response) => {
        const data = await response.json();
        if (data.results.bindings.length > 0) {
          // Only append the html when the document is ready
          $(document).ready(() => {
            try {
              $("div#content div.attributes")
                .first()
                .append('<div id="bcodmo-osprey-query"></div>');
              const newWrapper = $(
                "<div><hr/><strong>OSPREY:</strong><br></div>"
              );
              data.results.bindings.forEach((r) => {
                // Make sure the results look like we expect
                if ("uri" in r && "short_title" in r) {
                  const uri = r.uri.value;
                  const short_title = r.short_title.value;
                  newEl = $(`
                  <div>
                    ${short_title} <a
                      href="${uri}"
                      target="_blank">
                      ${uri}
                    </a>
                  </div>
                `);
                  newWrapper.append(newEl);
                }
              });
              $("#bcodmo-osprey-query").append(newWrapper);
            } catch (e) {
              console.warn("Failed in addOspreyInfo appending HTML");
              console.warn(e);
            }
          });
        }
      });
    }
  } catch (e) {
    console.warn("Failed in addOspreyInfo");
    console.warn(e);
  }
}

addOspreyInfo();
