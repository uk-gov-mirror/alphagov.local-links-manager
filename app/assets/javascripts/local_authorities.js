document.addEventListener('DOMContentLoaded', function (event) {
  var checkboxes = document.getElementsByClassName('links_status_checkbox')
  var linksDownloadButton = document.getElementById('links_download_button')
  var url = linksDownloadButton.href.split('?')[0]

  for (var i = 0; i < checkboxes.length; i++) {
    checkboxes[i].addEventListener('change', function () {
      var params = []
      for (var j = 0; j < checkboxes.length; j++) {
        if (checkboxes[j].checked) {
          params.push(checkboxes[j].name + '=' + checkboxes[j].value)
        }
      }
      linksDownloadButton.href = url + '?' + params.join('&')
    })
  }
})
