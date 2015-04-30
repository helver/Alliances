function do_delete(url)
{
  var request = new XMLHttpRequest();
  xx = request.open("DELETE", SiteURL + url, true);
  xx = request.send(null);
  //alert(xx);
  setTimeout("window.location.reload(true)", 500);
  //alert(request.responseText);
}


function really_submit(x_sub)
{
  //alert('DoSubmit: ' + x_sub); 

  if(x_sub == 1) { 
    return true; 
  } else { 
    return false;
  }
}


function ebay_reg_alert ()
{
  alert ("A new window will open up and will be in the Ebay SANDBOX (not the live site).\n\nPlease follow the instructions there to create your TEST account.\n\nNOTE: whatever name you provide ebay as your user name, you'll need to also let us know about when you tell us about your ebay account.");
}
