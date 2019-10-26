var scrollText = new Array();
function doScrollText(text)
{
	for(var i =0; i<text.length;i++)
	{
		var tmp = document.createElement("div");
		tmp.innerHTML = text.charAt(i);
		tmp.style['fontFamily'] = 'Courier New';
		tmp.style['fontWeight'] = 'bold';
		tmp.style['zindex'] = '5';
		tmp.style['position'] = "absolute";
		tmp.style['top'] = 300-(Math.pow(40+(i%80), 2)*0.2)+"px";
		tmp.style['left'] = (1000+i*10)+"px";
		scrollText.push(tmp);
		document.body.insertBefore(tmp, document.body.lastChild);
	}
}

function updateScroll()
{
	for(var i in scrollText)
	{
		var x = parseInt(scrollText[i].style['left'].substr(0, parseInt(scrollText[i].style['left'].length)-2));
		var y = Math.pow(40-(x%80), 2);
		var yy = parseInt(Math.cos(x*0.04)*10);
		scrollText[i].style['top'] = 300 + yy+"px";
		//scrollText[i].style['top'] = 300+y*0.02+"px";
		scrollText[i].style['left'] = x - 4+"px";
		if(x>0)
		{
		scrollText[i].style['color'] = "#"+d2h(255)+d2h(80+y%20)+""+d2h(y%255);
		scrollText[i].style['fontSize'] = 18+y*0.002+"px";
		}

		
	}
	if(scrollText[scrollText.length-1].style['left'].substr(0, parseInt(scrollText[scrollText.length-1].style['left'].length)-2)<8)
	{
		tscroll = clearInterval(tscroll);
		for(var i in scrollText)
		{
			document.body.removeChild(scrollText[i]);
		}
	}
}
var tscroll;
function scrollinit(text)
{
	doScrollText(text);
	tscroll = setInterval("updateScroll();", 10);
}

