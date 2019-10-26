/*
 * hypnotoad1k
 * js1k-2016 "Let's get eleMental!" entry
 * @author Gabor Bata
 * @license MIT
 */
var
    // image width
    W = 50,

    // image height
    H = 40,

    // image scale factor
    S = 8,

    // margin around image
    M = 10 * S,

    // pattern to split palette and compressed data
    A = /.{3}/g,

    // color palette
    P = 'fff000cb0b00430960ba5645cff700'.match(A),

    // canvas context
    c = window['a'].getContext('2d'),

    // helper variables
    x, y, j;

// draws a scaled pixel
function X(q, w, e) {
    c.fillStyle = '#' + P[e];
    c.fillRect(q * S + M, w * S + M, S, S);
}

// clears screen
X(0, 0, 0);
c.fillRect(0, 0, W * S + M * 2, H * S + M * 2);

// decompress image (x: substitution map, j: compresssed data)
// compression script can be found there: https://git.io/v2Czm
x =('~00z~~y66x55w44v11uzztyysxxrwwq51p01o77nttmvvlz~k41juuiw1hj' +
    'ug1sfl1exqdzpcribooa22`rr_1nZ1hY5wX4vWqhV5vUlpT1wSssR~pQ1xP' +
    '0vO0mNaaM2ZL23KL3JK3ImmH6gGnnFkrEicDdqCs5B88').match(A);
j = 'zO1umZUN21fNMfJ2vzvJMf3v131k~1k3v13ZfJ2TviJMfNvcNMlO`4m1khU' +
    '``Wf5`SWfxrwSehzgw4SsWRSSs4W~OIgQ4WRntvQ1YW~_ty61qYxZ~_tH54' +
    'xVu~P1uRntHeovuTXupGsqo1Xdcu_ns1o7TV~1`1UGebTep`1lPGvb15rxv' +
    '`kf7vntvb7Q5rVwFkzPo7Imbog5rqEz1VbbbbovsxY4qirkD6vb1717171o' +
    'vgYsxEdx1yIm1y6CksxEdx_1BB1tCkwsFwkDqty61BB1tCi4x5ElPqnmtH5' +
    'k54xXcuQ_nHqskczOQ_nygqYkczg1eGyveYFkz1qes_tmgqYF1fqxgV_gsq' +
    'xXrwvdesen6vgxm`wvzmCImgxvRwXXTklPeuzvqqdXpk~mu1VquDURiuDpu' +
    'Uudkufjjpl';
for (y = 54 /* x.length */; y--;) {
    j = j.replace(RegExp(x[y].charAt(0),'g'), x[y].slice(1));
}

// draws hypnotoad image
for (x = W; x--;) {
    for (y = H; y--;) {
        X(x, y, j.charAt(W * y + x));
    }
}

// eye animation
j = [9, 1, 9, 3, 9];
setInterval(function() {
    y = ++y % 4;
    for (x = 2; x--;) {
        for (A = 2; A--;) {
            X(7 + x * 13, A * 2 + 2, j[y + x]);
        }
    }
}, 150);
