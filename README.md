# arxivarius
Browser-based media library written on Ruby on Rails and Perl.
Reflects file system of various media with mapping files and directories to common names in Unicode
and allow to archive selected media. Tested on Windows.

<a href='https://integralsd.com/sergey/programming/arxivarius/'>Screenshots</a>

arxivarius is a web interface to view dirs/files on your harddrive.
It shows the files mp3 tags if any. 
Translates names of the dirs/files into russian from translit alphabetically/by patterns
or using translations stored in the database table 'translit'.

arxivarius consists of ruby on rails application (APP) and importer perl script (IMPORTER) lib/directory_tree.pl,
IMPORTER walks throgh all sub-directories of a specified directory and grabs all names into mysql database:
tables :directories, :fils (for files), :mp3tags
The importer reimports all data from scratch, there is no append functionality yet.

APP PRE-INSTALL
ruby rails
apache (to access files from browser)
mysql

IMPORTER PRE-INSTALL
perl
DBI
DBD::mysql
File::DirWalk
MP3::Tag

INSTALL
1) set up local mysql db called "arxivarius";
2) run migration: 
$$rake migrate
3) change start dir in the IMPORTER script and run it;
4) add line to apache httpd.conf:
Alias /music C:/Music
restart apache;

RUN
1) start ruby Webbrick server:
2) invoke localhost:3000 in browser.

MODIFY
Add more entries to :translit db table.

COMMENTS
Translation into Russian happens for any subdirectory of a directory
having word 'russian' in its name.

PLATFORMS
works on Win
APP should work on Unix
IMPORTER needs small change to work on Unix (change paths from \ to /)
