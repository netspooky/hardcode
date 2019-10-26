#!/usr/bin/perl
# This script finds the smallest compiled and processed size by iterating
# through several flags. Takes time.

$sources = 'src/organica.c';
$target = 'build/organica';

$flags_cc = '-I/usr/X11R6/include -I/usr/include -DHAVE_DLFCN_H -DDNLOAD_LIBGL -DDNLOAD_LIBGLU -DDNLOAD_LIBGLUT -DDNLOAD_LIBSDL -DDISCARD_LIBC ' . `sdl-config --cflags`;
$flags_ld = '-L/usr/local/lib -L/usr/X11R6/lib -lSDL -lpthread -nostdlib';

@compilers =
(
	#'gcc',
	'gcc41',
	'gcc42'
);
@flags_cc_opt =
(
	#'-O0',
	'-O1',
	#'-O2',
	#'-O3',
	#'-O4',
	'-Os'
);
@flags_cc_arch =
(
	'-march=i386',
	#'-march=i486',
	#'-march=i586',
	#'-march=pentium-mmx',
	#'-march=pentiumpro',
	'-march=pentium2',
	#'-march=pentium3',
	'-march=pentium4',
	#'-march=k6',
	#'-march=k6-2',
	#'-march=athlon',
	#'-march=athlon-xp',
	'-march=k8',
);

@flags_cc_variadic =
(
	'-DDNLOAD_LIBM',
	'-ffast-math',
	'-fmerge-all-constants',
	'-fmodulo-sched',
	'-fno-inline',
	'-fno-peephole',
	'-fomit-frame-pointer',
	'-ftracer',
	'-fweb',
	#'-fwhole-program',
	'-mpreferred-stack-boundary=2'
);

sub ipow
{
	local $exp = pop(@_);

	if($exp == 0)
	{
		return 1;
	}

	local $base = pop(@_);

	local $i, $ret = $base;
	for($i = 1; ($i < $exp); ++$i)
	{
		$ret *= $base;
	}

	return $ret;
}

sub file_get_size
{
	@statret = stat(pop(@_));
	return $statret[7];
}

sub pack_binary
{
	local $flags_strip = '-K .bss -K .text -K .data -R .comment -R .note -R .note.ABI-tag -R .fini -R .gnu.version';
	#local $unpackhdr = 'dd bs=1 skip=66<$0|gunzip>/tmp/i;cd /tmp;chmod +x i;./i;rm i;exit';
	local $unpackhdr = 'tail -n+2 $0>/tmp/i.7z;cd /tmp;7z x -so i.7z>i;chmod +x i;./i;rm i i.7z;exit';

	local $tgt = pop(@_);
	local $src = pop(@_);

	print "Packing ${src}, size " . &file_get_size($src);

	# Perform strip.
	local @strip_command = split(/ /, "strip ${flags_strip} ${src}");
	if(system(@strip_command) != 0)
	{
		print "Error: strip command failed: @{strip_command}\n";
		exit 1;
	}

	#`cat unpackhdr_gzip > ${tgt}`;
	#`cat ${src} | gzip -c -9 -n >> ${target}`;

	`cat unpackhdr_7z > ${tgt}`;
	`cat ${src} | 7z a -t7z -mx=8 -si ${tgt}.7z`;
	`cat ${tgt}.7z >> ${tgt}`;

	local $size = &file_get_size($tgt);
	print " -> ${tgt}, size ${size}\n";
	return $size;
}

# Initialize minimum size to something... big.
$min_size = 999999;
@selected_flags = ();

for($opt_index = 0; ($opt_index < @flags_cc_opt); ++$opt_index)
{
	$opt = $flags_cc_opt[$opt_index];

	for($arch_index = 0; ($arch_index < @flags_cc_arch); ++$arch_index)
	{
		$arch = $flags_cc_arch[$arch_index];

		# Get the factorial
		$factorial = 1;
		for($ii = 0; $ii < @flags_cc_variadic; ++$ii)
		{
			$factorial *= 2;
		}

		$opt_round = @flags_cc_arch * $factorial;
		$total = @flags_cc_opt * $opt_round;

		# Now just iterate and add the thingies if they match the factorial.
		for($ii = 0; $ii < $factorial; ++$ii)
		{
			print('Running compile pass ' .
				($opt_index * $opt_round + $arch_index * $factorial + $ii) .
				" / $total\n");

			# The base flags the factorial stuff is added on.
			$flags = "$opt $arch $flags_cc $flags_ld";

			for($jj = 0; $jj < @flags_cc_variadic; ++$jj)
			{
				if(($ii / &ipow(2, $jj)) % 2 == 0)
				{
					$flags = $flags_cc_variadic[$jj] . " $flags";
				}
			}

			# Remove newline from flags.
			$flags =~ s/\n//;
			$flags =~ s/\r//;

			# Now we have the full flags.
			print "Compiling with flags: \"${flags}\":\n";

			foreach $cc (@compilers)
			{
				@split_flags = split(/ /, "$cc -o ${target}_unpacked $sources $flags");
				$return_value = system(@split_flags);
				print "Status: $return_value\n";
				if($return_value == 0)
				{
					$size = &pack_binary("${target}_unpacked", $target);
					if($size < $min_size)
					{
						$min_size = $size;
						@selected_flags = @split_flags;
					}
				}
			}
		}
	}
}

# After everything.
print "Smallest size was $min_size compiled with:\n@selected_flags\n\n" .
system(@selected_flags);
&pack_binary("${target}_unpacked", $target);
exit 0;
