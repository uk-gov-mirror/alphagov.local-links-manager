document.addEventListener("DOMContentLoaded", function(event) {
  var checkboxes = document.getElementsByClassName('links_status_checkbox');
  var links_download_button = document.getElementById('links_download_button');
  var url = links_download_button.href.split('?')[0];

  for (var i = 0; i < checkboxes.length; i++) {
    checkboxes[i].addEventListener('change', function() {
      var params = [];
      for (var j = 0; j < checkboxes.length; j++) {
        if (checkboxes[j].checked) {
          params.push(checkboxes[j].name + '=' + checkboxes[j].value)
        }
      }
      links_download_button.href = url + '?' + params.join('&')
    });
  }
});
