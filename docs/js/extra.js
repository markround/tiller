(function () {
  'use strict';
  //var languageCodeToNameMap = {en: 'English', de: 'Deutsch'};
  var languageCodeToNameMap = {en: 'English'};
  var languageNames = values(languageCodeToNameMap);
  var defaultLanguageCode = 'en';

  $(document).ready(function () {
    fixSearch();
  });

  /*
   * RTD messes up MkDocs' search feature by tinkering with the search box defined in the theme, see
   * https://github.com/rtfd/readthedocs.org/issues/1088. This function sets up a DOM4 MutationObserver
   * to react to changes to the search form (triggered by RTD on doc ready). It then reverts everything
   * the RTD JS code modified.
   */
  function fixSearch() {
    var target = document.getElementById('rtd-search-form');
    var config = {attributes: true, childList: true};

    var observer = new MutationObserver(function(mutations) {
      // if it isn't disconnected it'll loop infinitely because the observed element is modified
      observer.disconnect();
      var form = $('#rtd-search-form');
      form.empty();
      form.attr('action', 'https://' + window.location.hostname + '/en/' + determineSelectedBranch() + '/search.html');
      $('<input>').attr({
        type: "text",
        name: "q",
        placeholder: "Search docs"
      }).appendTo(form);
    });

    if (window.location.origin.indexOf('readthedocs') > -1) {
      observer.observe(target, config);
    }
  }


  function values(associativeArray) {
    var values = [];
    for (var key in associativeArray) {
      if (associativeArray.hasOwnProperty(key)) {
        values.push(associativeArray[key]);
      }
    }
    return values;
  }
}());
