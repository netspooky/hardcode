// compress using regpack
b.bgColor = "#36f",
    A = new AudioContext,
    C = A.createScriptProcessor(a.width = 1024, s = 0, 1),
    C.connect(A.destination),
    P = [],
    C.onaudioprocess = function (b) {
        for (a.height = 480,
                 b = b.outputBuffer.getChannelData(d = 0),
                 c.fillStyle = "#9cf",
                 c.font = "116px serif",
                 c.fillText("☁", 7 * s % 1336 - 226, 226),
                 c.font = "226px serif",
                 c.fillText("☁", 9 * s % 1336 - 226, 226),
                 c.font = "66px serif",
                 c.fillText("☁", 4 * s % 1336 - 226, 226),
                 c.fillText("☁", 6 * s % 1336 - 226, 226);
             d < 1024; s += 6 / A.sampleRate)
            c.fillStyle = "#003",
                c.fillRect(0, d, 1024, d < 336 ? 1 - d / 336 : 1),
                c.fillRect(d, 336 + (b[d++] = (22 * s * Math.pow(1.059463, parseInt("bbnqbbnn99lljjvzeeqqeellggggsnnzbbnnbbnn99lljjvzeeqqeeqqggggllxxlllleeqqaamybbnn99lleeii66iibbnq99lo77jn77jj77jneeqqggssnnnnbbnqeennllllbbnueenn99lpjjjjjjjjjjjjjjeeiillllll77lu11449999bbbb6622222222bbccggjjjjjjjjjjoonniieeeeeeeeeeebeeiillllllllllqqppllggggggggggll    qqqtsqooqqqqqqooomlommmmllllllqqqqqtsqooqqqqqqqsttttvvvvssstsqosttttssssqqqtsqosttttssssqqqtsqooqqqqqqqqqqqqomlommmmllllllllllllllllllllllllllooqqhhhhhhmljmoohhhhhhllhhmmooooovovtvttssqqllllllgghhrrrrrrrrrrrrrrrrxxttttttssttstqtttmmmmmmmmmmmmmmjjggggggeeggegcc"[0 | s % 264 + (d & 1) * 264], 36) + (d & 1) * 9) & 1) - .5), 4, 226 * Math.sin(d / 116) + 16 * Math.sin(d / 16));
        c.fillStyle = "#f6f",
            c.fillText("MENTAL", 420, 200),
            c.fillText("ISLAND", 480, 250),
            c.font = "16px serif",
            c.fillText("THE SECRET OF", 480, 150);

        for (;d-=16;) {
            if(!P[d]||!P[d][0])
                P[d] = [
                    d/16,
                    520,
                    130
                ]
             else
                P[d][0]--,
                P[d][1]+=Math.random()/2-.1,
                P[d][2]-=Math.random()/2;
            c.fillStyle = '#f41';
            c.fillRect(P[d][1],P[d][2],2,2);
        }
    }
