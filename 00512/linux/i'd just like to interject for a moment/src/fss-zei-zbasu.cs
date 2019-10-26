/*
 * This file is part of "fingubni samselpla selsa'a" (FSS)
 * Copyright (C) 2017 PoroCYon
 *
 * FSS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3,
 * or at your option, any later version, as
 * published by the Free Software Foundation.
 *
 * FSS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FSS. If not, see <https://www.gnu.org/licenses/>.
 */
/*
 * lo ti datnyvei cu pagbu la fingubni samselpla selsa'a goi fysysy
 * noi proga gi'e se fukyzifpo'e la'oi PoroCYon de'i li 2017
 *
 * .i fysysy fingubni .ija'ebo do .e'a ti fairgau gi'e galfi
 * ti ja'i la'o gy. GNU General Public License .gy poi se versiio
 * li su'o 3 gi'e se finti la'o gy. Free Software Foundation .gy
 *
 * .i fysysy se fairgau tezu'e lo nu plixau SECAU LO SI'O SIDJU kuku'i
 * .i .e'u ko catlu gypyly tezu'e lo nu zvafa'i lo tcila
 *
 * .i .a'o do te bevri lo fukpi be gypyly sepa'u fysysy .i va'onai
 * la'edi'u ko catlu zoi .url. https://www.gnu.org/licenses/ .url.
 */

// .u'u sa'urgau la monos .iku'i la'o gy. coreutils .gy na satci fi lo
// nilbra pe lo bivjetka'u .ije lo ka ce'u ti samselpla bau la sis cu
// fanza

using System;
using System.IO;
using System.Text;

static class Proga
{
    static void Main(string[] args)
    {
        string terzba = args[0];
        string proga  = args[1];
        string zss    = args[2];

        // la'o cysy. File.OpenWrite .cysy na cmagau lo datnyvei
        // va'o lo nu cmamau lo laldo
        if (File.Exists(zss))
            File.Delete(zss);
        using (FileStream zfs = File.OpenWrite(zss))
        {
            using (BinaryWriter zbw = new BinaryWriter(zfs))
            {
                // ca'e vimcu lo nalvai lerpinsle
                string[] lerpinsle = File.ReadAllLines(terzba);
                string romoi = lerpinsle[lerpinsle.Length - 1] + '\n';
                byte[] romoi_bivjetkahu = Encoding.ASCII.GetBytes(romoi);
                zbw.Write(romoi_bivjetkahu);

                zbw.Write(File.ReadAllBytes(proga));
            }
        }
    }
}

