/*
 * jQuery Corners 0.2
 *
 * Copyright (c) 2008 David Turnbull, Steven Wittens
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 */


jQuery.fn.corners = function(options) {
  var settings = parseOptions(options);
  var webkitAvailable = false;
  try {
    webkitAvailable = (document.defaultView.getComputedStyle(this[0], null)['-webkit-border-radius'] != undefined);
  } catch(err) {}
  return this.each(function(){
    //TODO prevent rounding more than once
    var class_scan = /{(.*)}/.exec(this.className)
    var s = class_scan ? parseOptions(class_scan[1], settings) : settings
    if (webkitAvailable && s.webkit) roundWebkit(this, s);
    else {
      var bgColor = backgroundColor(this.parentNode);
      var fgColor = backgroundColor(this);
      switch (this.nodeName.toLowerCase()) {
        case 'a':
          roundLink(this, s, bgColor, fgColor);
          break;
        case 'input':
          roundInput(this, s, bgColor, fgColor);
          break;
        default:
          roundDiv(this, s, bgColor, fgColor);
          break;
      }
    }
  });
  
  function roundWebkit(e, s) {
    if (s.transparent) {
      var radius = '' + (s.sizex+1) + 'px ' + (s.sizey+1) + 'px';
    } else {
      var radius = '' + s.sizex + 'px ' + s.sizey + 'px';
    }
    if (s.tl) jQuery(e).css('WebkitBorderTopLeftRadius', radius);
    if (s.tr) jQuery(e).css('WebkitBorderTopRightRadius', radius);
    if (s.bl) jQuery(e).css('WebkitBorderBottomLeftRadius', radius);
    if (s.br) jQuery(e).css('WebkitBorderBottomRightRadius', radius);
  }
  
  function roundLink(e, s, bgColor, fgColor) {
    var table = tableElement("table");
    var tbody = tableElement("tbody");
    table.appendChild(tbody);
    var tr1 = tableElement("tr");
    var td1 = tableElement("td", "top");
    tr1.appendChild(td1);
    var tr2 = tableElement("tr");
    var td2 = relocateContent(e, s, tableElement("td"));
    tr2.appendChild(td2);
    var tr3 = tableElement("tr");
    var td3 = tableElement("td", "bottom");
    tr3.appendChild(td3);
    if (s.tl||s.tr) {
      tbody.appendChild(tr1);
      addCorners(td1, s, bgColor, fgColor, true)
    }
    tbody.appendChild(tr2);
    if (s.bl||s.br) {
      tbody.appendChild(tr3);
      addCorners(td3, s, bgColor, fgColor, false)
    }
    e.appendChild(table);
    /* Clicking on {a>table} in IE will trigger onclick but not the href  */
    if (jQuery.browser.msie) table.onclick = ieLinkBypass;
    /* Firefox 2 will render garbage unless we hide the overflow here */
    e.style.overflow = 'hidden';
  }
  
  function ieLinkBypass() {
    if (!this.parentNode.onclick) this.parentNode.click();
  }
  
  function roundInput(e, s, bgColor, fgColor) {
    //TODO test image buttons should be translatable
    //TODO possibly emulate value and disabled attributes??
    var a1 = document.createElement("a");
    a1.href = parentForm(e).action
    a1.id = e.id;
    a1.className = e.className;
    if (e.onclick) a1.onclick = e.onclick;
    else a1.onclick = submitForm;
    var a2 = document.createTextNode(e.value);
    a1.appendChild(a2);
    e.parentNode.replaceChild(a1, e);
    roundLink(a1, s, bgColor, fgColor);
  }
  
  function submitForm() {
    parentForm(this).submit();
    return false;
  }

  function parentForm(e) {
    if (e.nodeName.toLowerCase() == 'form') return e
    return parentForm(e.parentNode);
  }

  function roundDiv(e, s, bgColor, fgColor) {
    var div = relocateContent(e, s, document.createElement('div'));
    e.appendChild(div);
    if (s.tl||s.tr) addCorners(e, s, bgColor, fgColor, true);
    if (s.bl||s.br) addCorners(e, s, bgColor, fgColor, false);
  }
  
  function relocateContent(e, s, d) {
    var $e = jQuery(e);
    var c;
    while(c=e.firstChild) d.appendChild(c);
    if (e.style.height) {
      var h = parseInt($e.css('height'))
      d.style.height = h + 'px';
      h += parseInt($e.css('padding-top')) + parseInt($e.css('padding-bottom'))
      e.style.height = h + 'px';
    }
    if (e.style.width) {
      var w = parseInt($e.css('width'))
      d.style.width = w + 'px';
      w += parseInt($e.css('padding-left')) + parseInt($e.css('padding-right'))
      e.style.width = w + 'px';
    }
    d.style.paddingLeft = $e.css('padding-left');
    d.style.paddingRight = $e.css('padding-right');
    if (s.tl||s.tr) {
      d.style.paddingTop = adjustedPadding(e, s, $e.css('padding-top'), true);
    } else {
      d.style.paddingTop = $e.css('padding-top');
    }
    if (s.bl||s.br) {
      d.style.paddingBottom = adjustedPadding(e, s, $e.css('padding-bottom'), false);
    } else {
      d.style.paddingBottom = $e.css('padding-bottom');
    }
    e.style.padding = 0;
    return d;
  }
  
  function adjustedPadding(e, s, pad, top) {
    if (pad.indexOf("px") < 0) {
      try {
        //TODO Make this check work otherwise remove it
        console.error('%s padding not in pixels', (top ? 'top' : 'bottom'), e);
      }
      catch(err) {}
      pad = s.sizey + 'px'
    }
    pad = parseInt(pad);
    if (pad - s.sizey < 0) {
      try {
        console.error('%s padding is %ipx for %ipx corner:', (top ? 'top' : 'bottom'), pad, s.sizey, e);
      }
      catch(err) {}
      pad = s.sizey;
    }
    return pad - s.sizey + 'px';
  }

  function tableElement(kind, valign) {
    var e = document.createElement(kind)
    e.style.border = 'none';
    e.style.borderCollapse = 'collapse';
    e.style.borderSpacing = 0;
    e.style.padding = 0;
    e.style.margin = 0;
    if (valign) e.style.verticalAlign = valign;
    return e;
  }
  
  function backgroundColor(e) {
    try {
      var c = jQuery.css(e, "background-color");
      if ( c.match(/^(transparent|rgba\(0,\s*0,\s*0,\s*0\))$/i) && e.parentNode )
         return backgroundColor(e.parentNode);
      if (c==null)
        return "#ffffff";
      if (c.indexOf("rgb") > -1)
    	  c = rgb2hex(c);
      if (c.length == 4)
  	    c = hexShort2hex(c);
      return c;
    } catch(err) {
      return "#ffffff";
    }
  }
  
  function hexShort2hex(c) {
    return '#' +
    c.substring(1,2) +
    c.substring(1,2) +
    c.substring(2,3) +
    c.substring(2,3) +
    c.substring(3,4) +
    c.substring(3,4);
  }

  function rgb2hex(c) {
  	var x = 255;
  	var hex = '';
  	var i;
  	var regexp=/([0-9]+)[, ]+([0-9]+)[, ]+([0-9]+)/;
  	var array=regexp.exec(c);
  	for(i=1;i<4;i++) hex += ('0'+parseInt(array[i]).toString(16)).slice(-2);
  	return '#'+hex;
  }
  
  function parseOptions(options, settings) {
    var options = options || '';
    var s = {sizex:4, sizey:4, tl: false, tr: false, bl: false, br: false, webkit:true, transparent:false};
    if (settings) {
      s.sizex = settings.sizex;
      s.sizey = settings.sizey;
      s.webkit = settings.webkit;
      s.transparent = settings.transparent;
    }
    var sizex_set = false;
    var corner_set = false;
    jQuery.each(options.split(' '), function(idx, option) {
      option = option.toLowerCase();
      var i = parseInt(option);
      if (i > 0 && option == i + 'px') {
        s.sizey = i;
        if (!sizex_set) s.sizex = i;
        sizex_set = true;
      } else {
        if (option == 'webkit') s.webkit = true;
        if (option == 'nowebkit') s.webkit = false;
        if (option == 'anti-alias') s.transparent = false;
        if (option == 'transparent') s.transparent = true;
        if (option == 'top') corner_set = s.tl = s.tr = true;
        if (option == 'right') corner_set = s.tr = s.br = true;
        if (option == 'bottom') corner_set = s.bl = s.br = true;
        if (option == 'left') corner_set = s.tl = s.bl = true;
        if (option == 'top-left') corner_set = s.tl = true;
        if (option == 'top-right') corner_set = s.tr = true;
        if (option == 'bottom-left') corner_set = s.bl = true;
        if (option == 'bottom-right') corner_set = s.br = true;
      }
    });
    if (!corner_set) {
      if (!settings) {
        s.tl = s.tr = s.bl = s.br = true;
      } else {
        s.tl = settings.tl;
        s.tr = settings.tr;
        s.bl = settings.bl;
        s.br = settings.br;
      }
    }
    return s;
  }
  
  function alphaBlend(a, b, alpha) {
    var ca = Array(
      parseInt('0x' + a.substring(1, 3)),
      parseInt('0x' + a.substring(3, 5)),
      parseInt('0x' + a.substring(5, 7))
    );
    var cb = Array(
      parseInt('0x' + b.substring(1, 3)),
      parseInt('0x' + b.substring(3, 5)),
      parseInt('0x' + b.substring(5, 7))
    );
    r = '0' + Math.round(ca[0] + (cb[0] - ca[0])*alpha).toString(16);
    g = '0' + Math.round(ca[1] + (cb[1] - ca[1])*alpha).toString(16);
    b = '0' + Math.round(ca[2] + (cb[2] - ca[2])*alpha).toString(16);
    return '#'
      + r.substring(r.length - 2)
      + g.substring(g.length - 2)
      + b.substring(b.length - 2);
  }

  function addCorners(e, s, bgColor, fgColor, top) {
    if (s.transparent) addTransparentCorners(e, s, bgColor, top);
    else addAntiAliasCorners(e, s, bgColor, fgColor, top);
  }
  
  function addAntiAliasCorners(e, s, bgColor, fgColor, top) {
    var i, j;
    var d = document.createElement("div");
    d.style.fontSize = '1px';
    d.style.backgroundColor = bgColor;
    var lastarc = 0;
    for (i = 1; i <= s.sizey; i++) {
      var coverage, arc2, arc3;
      // Find intersection of arc with bottom of pixel row
      arc = Math.sqrt(1.0 - Math.pow(1.0 - i / s.sizey, 2)) * s.sizex;
      // Calculate how many pixels are bg, fg and blended.
      var n_bg = s.sizex - Math.ceil(arc);
      var n_fg = Math.floor(lastarc);
      var n_aa = s.sizex - n_bg - n_fg;
      // Create pixel row wrapper
      var x = document.createElement("div");
      var y = d;
      x.style.margin = "0px " + n_bg + "px";
      x.style.height = '1px';
      x.style.overflow = 'hidden';
      // Create the pixel divs for a row (at least one)
      for (j = 1; j <= n_aa; j++) {
        // Calculate coverage per pixel (approximates arc within the pixel)
        if (j == 1) {
          if (j == n_aa) {
            // Single pixel
            coverage = ((arc + lastarc) * .5) - n_fg;
          }
          else {
            // First in a run
            arc2 = Math.sqrt(1.0 - Math.pow(1.0 - (n_bg + 1) / s.sizex, 2)) * s.sizey;
            coverage = (arc2 - (s.sizey - i)) * (arc - n_fg - n_aa + 1) * .5;
          }
        }
        else if (j == n_aa) {
          // Last in a run
          arc2 = Math.sqrt(1.0 - Math.pow((s.sizex - n_bg - j + 1) / s.sizex, 2)) * s.sizey;
          coverage = 1.0 - (1.0 - (arc2 - (s.sizey - i))) * (1.0 - (lastarc - n_fg)) * .5;
        }
        else {
          // Middle of a run
          arc3 = Math.sqrt(1.0 - Math.pow((s.sizex - n_bg - j) / s.sizex, 2)) * s.sizey;
          arc2 = Math.sqrt(1.0 - Math.pow((s.sizex - n_bg - j + 1) / s.sizex, 2)) * s.sizey;
          coverage = ((arc2 + arc3) * .5) - (s.sizey - i);
        }
        
        addCornerDiv(s, x, y, top, alphaBlend(bgColor, fgColor, coverage));
        y = x;
        var x = y.cloneNode(false);
        x.style.margin = "0px 1px";
      }
      addCornerDiv(s, x, y, top, fgColor);
      lastarc = arc;
    }
    if (top)
      e.insertBefore(d, e.firstChild);
    else
      e.appendChild(d);
  }
  
  function addCornerDiv(s, x, y, top, color) {
    if (top && !s.tl) x.style.marginLeft = 0;
    if (top && !s.tr) x.style.marginRight = 0;
    if (!top && !s.bl) x.style.marginLeft = 0;
    if (!top && !s.br) x.style.marginRight = 0;
    x.style.backgroundColor = color;
    if (top)
      y.appendChild(x);
    else
      y.insertBefore(x, y.firstChild);
  }

  function addTransparentCorners(e, s, bgColor, top) {
    var d = document.createElement("div");
    d.style.fontSize = '1px';
    var strip = document.createElement('div');
    strip.style.overflow = 'hidden';
    strip.style.height = '1px';
    strip.style.borderColor = bgColor;
    strip.style.borderStyle = 'none solid';
    
    for (var i=0; i < s.sizey; i++) {
      var w = s.sizex - Math.floor(Math.sqrt(1.0 - Math.pow(1.0 - i / s.sizey, 2)) * s.sizex);
      var x = strip.cloneNode(false);
      x.style.borderWidth = '0 '+ w +'px';
      if (top) x.style.borderWidth = '0 '+(s.tr?w:0)+'px 0 '+(s.tl?w:0)+'px';
      else x.style.borderWidth = '0 '+(s.br?w:0)+'px 0 '+(s.bl?w:0)+'px';
      top ? d.appendChild(x) : d.insertBefore(x, d.firstChild);
    } 
    if (top)
      e.insertBefore(d, e.firstChild);
    else
      e.appendChild(d);
  }


}
