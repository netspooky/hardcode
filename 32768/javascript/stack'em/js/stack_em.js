/* ======================================================================== */
/*  Stack'Em - by Arnauld Chevallier                                        */
/*  Version 1.0 - Nov. 17, 2008                                             */
/* ------------------------------------------------------------------------ */
/*  a_chevallier [at] yahoo [dot] com                                       */
/*  http://knox.ac.free.fr                                                  */
/* ======================================================================== */
var stack_em = new function()
{
  /* ---------------------------------------------------------------------- */
  /*  Default speed is 1000 / 25 = 40 frames per second.                    */
  /*  You may want to change that.                                          */
  /*  Or not.                                                               */
  /* ---------------------------------------------------------------------- */
  var tick_p = 25;

  /* ---------------------------------------------------------------------- */
  /*  Other variables                                                       */
  /* ---------------------------------------------------------------------- */
  var b = new Array(),
      col = new Array(),
      nxt = new Array(),
      xbonus = Array(0, 1, 2, 2, 1, 0),
      x = 0, y = 0,
      keyMask = 0, keyHold = 0,
      keyMap = { 16:0x01, 17:0x02, 37:0x04, 38:0x08, 39:0x10, 40:0x20 },
      score = 0, bonus = 0, jewels = 0,
      start_l = 0, level = 0, levTh = 0,
      task = null, cnt = 0, frame = 0,
      title = 1, autoX = -1, autoR = 0;

  /* ---------------------------------------------------------------------- */
  /*  Let's make sure to get alive                                          */
  /* ---------------------------------------------------------------------- */
  if(window.addEventListener)
    window.addEventListener("load", init, false);
  else if(window.attachEvent)
    window.attachEvent("onload", init);

  /* ---------------------------------------------------------------------- */
  /*  $()                                                                   */
  /* ---------------------------------------------------------------------- */
  function $(id)
  {
    return document.getElementById(id);
  }

  /* ---------------------------------------------------------------------- */
  /*  init()                                                                */
  /* ---------------------------------------------------------------------- */
  function init()
  {
    if(!drawBoard()) return;

    document.onkeydown = function(event) { keyDown(event); };
    document.onkeyup = function(event) { keyUp(event); };

    for(var n = 0; n < 13; n++)
      b[n] = new Array();

    initBoard();
    initScore();
    setTask(newBlock);
    tick();
  }

  /* ---------------------------------------------------------------------- */
  /*  setTask()                                                             */
  /* ---------------------------------------------------------------------- */
  function setTask(t)
  {
    cnt = 0;
    task = t;
  }

  /* ---------------------------------------------------------------------- */
  /*  tick()                                                                */
  /* ---------------------------------------------------------------------- */
  function tick()
  {
    frame++;
    cnt++;

    if(title) title_task();
    task();

    setTimeout(tick, tick_p);
  }

  /* ---------------------------------------------------------------------- */
  /*  title_task()                                                          */
  /* ---------------------------------------------------------------------- */
  function title_task()
  {
    $("se_msg").style.display = (frame & 32) ? "none" : "block";

    if(title == 1) {
      if(keyMask & 0x03) {
        initScore();
        $("se_msg_p").innerHTML = "Select<br />starting level";
        $("se_over").innerHTML =
          '<span id="se_l0" style="color:#456;">easy</span><br />' +
          '<span id="se_l1" style="color:#456;">medium</span><br />' +
          '<span id="se_l2" style="color:#456;">hard</span>';
        $("se_over").style.top = 55;
        keyHold = 1;
        title++;
      }
    }
    else {
      level = 1 + start_l * 5;
      dispAll();

      for(var i = 0; i < 3; i++)
        $("se_l" + i).style.color = "#" + (start_l == i ? "fff" : "456");

      if(!keyMask) keyHold = 0;
      if(keyHold) return;

      if(keyMask & 0x20) { start_l = (start_l + 1) % 3; keyHold = 1; }
      else if(keyMask & 0x08) { start_l = (start_l + 2) % 3; keyHold = 1; }

      if(keyMask & 0x03) {
        title = 0;
        initBoard();
        setTask(newBlock);
        $("se_bubble").style.display = "none";
        $("se_over").style.display = "none";
        $("se_msg").style.display = "none";
      }
    }
  }

  /* ---------------------------------------------------------------------- */
  /*  keyDown()                                                             */
  /* ---------------------------------------------------------------------- */
  function keyDown(e)
  {
    keyMask |= keyMap[(e ? e : window.event).keyCode];
  }

  /* ---------------------------------------------------------------------- */
  /*  keyUp()                                                               */
  /* ---------------------------------------------------------------------- */
  function keyUp(e)
  {
    keyMask &= ~keyMap[(e ? e : window.event).keyCode];
  }

  /* ---------------------------------------------------------------------- */
  /*  initBoard()                                                           */
  /* ---------------------------------------------------------------------- */
  function initBoard()
  {
    for(var x = 0; x < 6; x++)
      for(var y = 0; y < 13; y++)
        setB(x, y, 0, true);

    next();
  }

  /* ---------------------------------------------------------------------- */
  /*  initScore()                                                           */
  /* ---------------------------------------------------------------------- */
  function initScore()
  {
    score = jewels = 0;
    level = 1;
    levTh = 35;

    dispAll();
  }

  /* ---------------------------------------------------------------------- */
  /*  drawBoard()                                                           */
  /* ---------------------------------------------------------------------- */
  function drawBoard()
  {
    var el;

    var html =
      '<div id="se_wrapper">' +
        '<div id="se_field_wrapper" class="se_border">' +
          '<div id="se_falling" class="se_blk">' +
            '<span id="se_fb0"></span><span id="se_fb1"></span><span id="se_fb2"></span>' +
          '</div>' +
          '<div id="se_field">';

    for(var n = 0; n < 78; n++)
      html += '<span id="se_b' + n + '" class="se_brick se_b0"></span>';

    html +=
          '</div>' +
        '</div>' +
        '<div id="se_bubble"></div>' +
        '<div id="se_title" class="se_txt">stack\'em</div>' +
        '<div id="se_over" class="se_txt">GAME<br />OVER</div>' +
        '<div id="se_author" class="se_txt">by A. Chevallier</div>' +
        '<div id="se_version" class="se_txt">v1.0</div>' +
        '<div id="se_next" class="se_blk se_border">' +
          '<span id="se_n0"></span><span id="se_n1"></span><span id="se_n2"></span>' +
        '</div>' +
        '<div id="se_menu">' +
          '<p class="se_p">Score</p><p id="se_score" class="se_p se_num se_border"></p>' +
          '<p class="se_p">Jewels</p><p id="se_jewels" class="se_p se_num se_border"></p>' +
          '<p class="se_p">Level</p><p id="se_level" class="se_p se_num se_border"></p>' +
        '</div>' +
        '<div id="se_msg">' +
          '<p id="se_msg_p" class="se_p">Press<br />Ctrl or Shift</p>' +
        '</div>' +
      '</div>';

    if(!(el = $("se_main"))) return false;

    el.innerHTML = html;
    return true;
  }

  /* ---------------------------------------------------------------------- */
  /*  updFB()                                                               */
  /* ---------------------------------------------------------------------- */
  function updFB()
  {
    var el = $("se_falling");

    el.style.top = y << 3;
    el.style.left = x << 4;

    for(var i = 0; i < 3; i++)
      $("se_fb" + i).className = "se_brick se_b" + col[i];
  }

  /* ---------------------------------------------------------------------- */
  /*  setB()                                                                */
  /* ---------------------------------------------------------------------- */
  function setB(x, y, n, scr)
  {
    if(x < 0 || x > 5 || y < 0 || y > 12) return;
    b[x][y] = n;
    if(scr) $("se_b" + (y * 6 + x)).className = "se_brick se_b" + (n & 7);
  }

  /* ---------------------------------------------------------------------- */
  /*  getB()                                                                */
  /* ---------------------------------------------------------------------- */
  function getB(x, y)
  {
    if(y < 0) return 0;
    if(x < 0 || x > 5 || y > 12) return -1;
    return b[x][y];
  }

  /* ---------------------------------------------------------------------- */
  /*  next()                                                                */
  /* ---------------------------------------------------------------------- */
  function next()
  {
    for(var i = 0; i < 3; i++) {
      col[i] = nxt[i];
      nxt[i] = Math.floor(Math.random() * 5) + 1;
      $("se_n" + i).className = "se_brick se_b" + nxt[i];
    }
  }

  /* ---------------------------------------------------------------------- */
  /*  newBlock()                                                            */
  /* ---------------------------------------------------------------------- */
  function newBlock()
  {
    x = 2;
    y = -4;
    next();
    updFB();

    setTask(b[2][0] ? gameOver : falling);
  }

  /* ---------------------------------------------------------------------- */
  /*  falling()                                                             */
  /* ---------------------------------------------------------------------- */
  function falling()
  {
    var t0 = col[0];
    var t1 = col[1];
    var t2 = col[2];
    var msk;

    if(title) {
      if(autoX == -1) {
        cpu();
        msk = 0;
      }
      else {
        if(autoR && y > 1 ) { if(msk = (frame & 3) ? 0 : autoR) autoR = 0; }
        else if(x < autoX) msk = (frame & 3) ? 0 : 0x10;
        else if(x > autoX) msk = (frame & 3) ? 0 : 0x04;
        else msk = y > 3 ? 0x20 : 0;
      }
    }
    else {
      if(keyHold) keyHold = keyMask ? keyHold - 1 : 0;
      msk = keyHold ? 0 : keyMask;
    }

    if(msk & 0x01) {
      col[0] = t1; col[1] = t2; col[2] = t0;
      keyHold = 50;
      updFB();
    }
    else if(msk & 0x02) {
      col[0] = t2; col[1] = t0; col[2] = t1;
      keyHold = 50;
      updFB();
    }
    if(msk & 0x04 && !getB(x - 1, ((y + 1) >> 1) + 2)) {
      x--;
      keyHold = 50;
      updFB();
    }
    else if(msk & 0x10 && !getB(x + 1, ((y + 1) >> 1) + 2)) {
      x++;
      keyHold = 50;
      updFB();
    }

    cnt += (level << 2) + 11;

    if((msk & 0x20) || cnt >= 100) {
      if(cnt >= 100) cnt -= 100;
      y++;
      if(getB(x, (y >> 1) + 3)) drop();
      updFB();
    }
  }

  /* ---------------------------------------------------------------------- */
  /*  drop()                                                                */
  /* ---------------------------------------------------------------------- */
  function drop()
  {
    setB(x, y >> 1, col[0], true);
    setB(x, (y >> 1) + 1, col[1], true);
    setB(x, (y >> 1) + 2, col[2], true);

    y = -6;
    bonus = 30;
    autoX = -1;

    setTask(chkPatterns);
  }

  /* ---------------------------------------------------------------------- */
  /*  chkPatterns()                                                         */
  /* ---------------------------------------------------------------------- */
  function chkPatterns()
  {
    var n, p, x, y, el;
    var xmin = 5, xmax = 0, ymin = 12, ymax = 0;

    if(!(n = patterns())) {
      setTask(newBlock);
      return;
    }

    p = (n - 3) * (n - 1) * 10 + bonus;
    bonus += 50;

    if(!title) {
      jewels += n;
      if(jewels >= levTh) { level++; levTh += 35; }
      score += p;

      dispAll();
    }

    for(y = 0; y < 13; y++)
      for(x = 0; x < 6; x++)
        if(b[x][y] & 8) {
          xmin = Math.min(xmin, x); xmax = Math.max(xmax, x);
          ymin = Math.min(ymin, y); ymax = Math.max(ymax, y);
        }

    el = $("se_bubble");
    el.innerHTML = p;
    el.style.top = (ymin + ymax + 1) << 3;
    el.style.left = ((xmin + xmax) << 3) + 105;
    el.style.display = "block";

    setTask(clear);
  }

  /* ---------------------------------------------------------------------- */
  /*  dispAll()                                                             */
  /* ---------------------------------------------------------------------- */
  function dispAll()
  {
    disp("se_score", score, 6);
    disp("se_jewels", jewels, 5);
    disp("se_level", level, 2);
  }

  /* ---------------------------------------------------------------------- */
  /*  disp()                                                                */
  /* ---------------------------------------------------------------------- */
  function disp(id, v, n)
  {
    var str = v + "";
    while(str.length < n) str = "0" + str;
    $(id).innerHTML = str;
  }

  /* ---------------------------------------------------------------------- */
  /*  cpu()                                                                 */
  /* ---------------------------------------------------------------------- */
  function cpu()
  {
    var x, y, r, n, score;
    var best = -1;

    for(x = 0; x < 6; x++) {
      for(y = 12; y >= 0 && b[x][y]; y--);
      for(r = 0; r < 3; r++) {
        setB(x, y - 2, col[r % 3], false);
        setB(x, y - 1, col[(r+1) % 3], false);
        setB(x, y, col[(r+2) % 3], false);

        n = patterns();
        score = (n << 6) + (y << 2) + xbonus[x];
        if(!n && col[r % 3] == col[(r+1) % 3]) score++;

        if(score > best) {
          best = score; autoR = r; autoX = x;
        }
      }
      setB(x, y - 2, 0, false);
      setB(x, y - 1, 0, false);
      setB(x, y, 0, false);
    }
  }

  /* ---------------------------------------------------------------------- */
  /*  patterns()                                                            */
  /* ---------------------------------------------------------------------- */
  function patterns()
  {
    var x, y;
    var n = 0;

    for(y = 0; y < 13; y++)
      for(x = 0; x < 6; x++)
        b[x][y] &= 7;

    for(y = 0; y < 13; y++) {
      for(x = 0; x < 6; x++) {
        n += chkAlign(x, y, 1, 0);
        n += chkAlign(x, y, 1, 1);
        n += chkAlign(x, y, 0, 1);
        n += chkAlign(x, y, -1, 1);
      }
    }

    return n;
  }

  /* ---------------------------------------------------------------------- */
  /*  chkAlign()                                                            */
  /* ---------------------------------------------------------------------- */
  function chkAlign(x, y, dx, dy)
  {
    var c, i;
    var n = 0;
    var f = 0;

    if(!(c = getB(x, y) & 7)) return 0;

    do {
      x += dx;
      y += dy;
      n++;
    } while((getB(x, y) & 7) == c);

    if(n < 3) return 0;

    for(i = 0; i < n; i++) {
      x -= dx;
      y -= dy;
      if(!(b[x][y] & 8)) { b[x][y] |= 8; f++; }
    }

    return f;
  }

  /* ---------------------------------------------------------------------- */
  /*  clear()                                                               */
  /* ---------------------------------------------------------------------- */
  function clear()
  {
    var x, y, el;

    el = $("se_bubble");

    if(cnt == 32)
      el.style.display = "none";
    else if(cnt & 1)
      el.style.top = (parseInt(el.style.top) - 1) + "px";

    for(y = 0; y < 13; y++) {
      for(x = 0; x < 6; x++) {
        if(b[x][y] & 8) {
          el = $("se_b" + (y * 6 + x));
          if(cnt & 4)
            el.className = el.className.substr(0, 14);
          else
            el.className += " se_flag";
        }
      }
    }

    if(cnt == 32) {
      for(y = 0; y < 13; y++)
        for(x = 0; x < 6; x++)
          if(b[x][y] & 8)
            setB(x, y, 8, true);

      setTask(scrolling);
    }
  }

  /* ---------------------------------------------------------------------- */
  /*  scrolling()                                                           */
  /* ---------------------------------------------------------------------- */
  function scrolling()
  {
    var x, y, y0;
    var done = true;

    if(cnt & 1) return;

    for(x = 0; x < 6; x++) {
      for(y = 12; y >= 0; y--) {
        if(b[x][y] & 8) {
          done = false;
          for(y0 = y; y0 >= 0; y0--) {
            setB(x, y0, getB(x, y0 - 1), true);
          }
        }
      }
    }

    if(done) setTask(chkPatterns);
  }

  /* ---------------------------------------------------------------------- */
  /*  gameOver()                                                            */
  /* ---------------------------------------------------------------------- */
  function gameOver()
  {
    if(title) cnt = 200;

    if(cnt <= 150) {
      $("se_over").innerHTML = "GAME<br />OVER";
      $("se_msg_p").innerHTML = "Press<br />Ctrl or Shift";
      $("se_over").style.display = "block";
      $("se_over").style.top = 75 + Math.cos(cnt / 10.0) * (150 - cnt) / 3.0;
    }
    else if(cnt == 200) {
      initBoard();
      title = 1;
      setTask(newBlock);
    }
  }
}();
