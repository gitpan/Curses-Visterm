#!/usr/bin/perl

use ExtUtils::MakeMaker;

WriteMakefile
  ( NAME         => 'Curses::Visterm',
    AUTHOR       => 'Rocco Caputo <rcaputo@cpan.org>',
    ABSTRACT     => 'Curses split-terminal interface for applications.',
    VERSION_FROM => 'Visterm.pm',
#    PM           => { 'Visterm.pm' => '$(INST_LIBDIR)/Visterm.pm' },
    PMLIBDIRS    => [ 'Visterm' ],
    PREREQ_PM    => { POE          => 0.19,
                      Curses       => '',
                    },
    dist         => { COMPRESS     => 'gzip -9f',
                      SUFFIX       => 'gz',
                    },
  );
