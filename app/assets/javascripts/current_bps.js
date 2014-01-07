function checktc() {
  if (document.getElementById('tac').checked) {
    return true;
    }
  else {
    document.getElementById('tac_error_msg').innerHTML = '<p>Please accept our terms and conditions above</p>';
    return false;
    }
}