//Texture include file
initlayers(512,512);
colorLayer(0,128,64,0);
perlinNoise(1,32,2054690560,128,105,5,false);
perlinNoise(2,32,654987072,128,110,8,false);
noiseDistort(2,2,544757248,2);
noiseDistort(2,2,118656432,5);
noiseDistort(2,2,115421472,6);
noiseDistort(2,2,115421472,8);
woodLayer(2,2,5);
makeTilable(2,2,64);
erodeLayer(2,2);
colorLayer(4,0,0,0);
addLayers(0,1,4,1,1);
addLayers(4,2,4,1,1);
addLayers(4,3,4,1,1);
