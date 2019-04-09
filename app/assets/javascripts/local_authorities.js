document.addEventListener("DOMContentLoaded", function(event) {
  var links_download_button = document.getElementById('links_download_button');
  var href = links_download_button.href;

  links_download_button.addEventListener('mouseenter', function() {
    var checkboxes = document.getElementsByClassName('link_status_checkbox');
    var params = [];
    for (var i = 0; i < checkboxes.length; i++) {
      if (checkboxes[i].checked) {
        params.push(checkboxes[i].name + '=' + checkboxes[i].value + '&')
      }
    }
    links_download_button.href = href + '?' + params.join('')
  });
});
