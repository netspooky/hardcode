var genericId = 0;
function produceSomething(Something)
{
	var nw = document.createElement(Something);
	nw.style['position'] = 'absolute';
	nw.style['left'] = "0px";
	nw.style['top'] = "0px";
	nw.id = "Generic_" + Something + "_" + incrementGenericId();
	return nw;
}

function produceSomethingText(Something, txt)
{
	var nw = document.createElement(Something);
	nw.style['position'] = 'absolute';
	nw.style['left'] = "0px";
	nw.style['top'] = "0px";
	nw.id = "Generic_" + Something + "_" + incrementGenericId();
	nw.innerHTML = txt;
	return nw;
}

function produceSomethingAdvanced(Something, txt, posX, posY)
{
	var nw = document.createElement(Something);
	nw.style['position'] = 'absolute';
	nw.style['left'] = posX + "px";
	nw.style['top'] = posY + "px";
	nw.id = "Generic_" + Something + "_" + incrementGenericId();
	nw.innerHTML = txt;
	return nw;
}

function incrementGenericId(){
	genericId = genericId + 1;
	return genericId;
}