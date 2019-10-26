fake_plastic_cubes_part_2.png.html: pnginator.rb fpc2.min.js 195.unvtx shader.fs shader.vs
	ruby pnginator.rb fpc2.min.js 195.unvtx shader.fs shader.vs fake_plastic_cubes_part_2.png.html
	ls -l fake_plastic_cubes_part_2.png.html

195.unvtx: 195.psg psg2unvtx.py
	python psg2unvtx.py 195.psg 195.unvtx

fpc2.min.js: ay_chip.js dynamic_audio.js unvtx_file.js mat4.js mat3.js main.js
	java -jar compiler.jar --js=ay_chip.js --js=dynamic_audio.js --js=unvtx_file.js --js=mat4.js --js=mat3.js --js=main.js --js_output_file=fpc2.min.js
