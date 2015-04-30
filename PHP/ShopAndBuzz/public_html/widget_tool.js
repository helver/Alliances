var use_text = false;
var img_name = "";
var text_text = "";

function recalc_widget(tform, user)
{
  dest = tform.elements['widget_code'];
  
  if(img_name) {
    xx = "<a href=\"" + SiteURL + "/users/" + user + "/\"><img align=\"absmiddle\" src=\"" + SiteURL + "/thematics/" + img_name + "\" /></a>";
  } else {
    xx = "";
  }
  
  if(use_text) {
    xx += text_text;
  }
  //alert(xx);
  dest.value = xx;
}


