#! D://Perl/bin/perl.exe

require "cgi-lib.pl";

print "<h2>—бор новых директорий/файлов в базу данных</h2>";



use CGI::Carp qw(fatalsToBrowser);

#browse directories recursively and populates mysql table with dit/files info

use File::DirWalk;
use MP3::Tag;

require "db.pl";

###mysql table/fields to populate
$dirs_table = 'directories'; $files_table = 'fils'; $mp3tags_table = 'mp3tags';

@dirs_start = ('E:\\ћузыка','E:\\јудио ниги');

print "<br>get all existing in DB dir paths";

#get all existing in DB dir paths
undef(%dir_paths);undef($dir_paths);
$sql0 = $dbh->prepare("
                SELECT id, path
                FROM $dirs_table ");

        $sql0->execute;
        while(($id,$path)=$sql0->fetchrow_array) {
                $dir_paths{$path} = $id;
        }
        $sql0->finish;

print "<br>get all existing in DB fil paths";
#get all existing in DB fil paths
undef(%fil_paths);undef($fil_paths);
$sql0 = $dbh->prepare("
                SELECT path
                FROM $files_table ");

        $sql0->execute;
        while(($path)=$sql0->fetchrow_array) {
                $fil_paths{$path} = 1;
        }
        $sql0->finish;

############ get the last ids

print "<br>get last dir_id";
#get last dir_id
$sql0 = $dbh->prepare("
                SELECT id
                FROM $dirs_table
                ORDER BY id DESC
                LIMIT 1");

        $sql0->execute;
        ($id)=$sql0->fetchrow_array;
        $sql0->finish;

print "<br>get lst fil_id";
#get lst fil_id
$sql0 = $dbh->prepare("
                SELECT id
                FROM $files_table
                ORDER BY id DESC
                LIMIT 1");

        $sql0->execute;
        ($fil_id)=$sql0->fetchrow_array;
        $sql0->finish;



############ begin walking

print "<br>begin walking";
my $dw = new File::DirWalk;
$dw->onDirEnter(sub {
        my ($dir) = @_;
        $id++;
        $parent_dir = reverse($dir);
        $parent_dir =~ s/(.+?)\\//;
        $parent_dir = reverse($parent_dir);
        $parent_id = $directory_id{$parent_dir};
#print "<br>dir:$dir";
        $name = reverse($dir);
        $name =~ s/\\.*//;
        $name = reverse($name);

        $path_qt = $dbh->quote($dir);
        $name_qt = $dbh->quote($name);

        $level = &find_count_occur($dir,'\\\\');

        #check if path already exists
        if (!$dir_paths{$dir}) {
                $directory_id{$dir} = $id;
                if(!($id>0)){print "<br><font color=red>no id:$id</font>";exit;}
                if(!($level>0)){print "<br><font color=red>no level:$level</font>";exit;}
                if(!($parent_id>0)){print "<br><font color=red>No parent_id</font>"; $parent_id = 0;}

                $dbh->do("INSERT INTO $dirs_table SET id=$id, parent_id=$parent_id, level=$level, name=$name_qt, path=$path_qt");
                print "<br>$dir, level:$level, id:$id, par:$parent_id:$parent_dir";
        } else {
                $directory_id{$dir} = $dir_paths{$dir};
        }
        return File::DirWalk::SUCCESS;
});

$dw->onFile(sub {
        my ($file) = @_;
        $fil_id++;

        $parent_dir = reverse($file);
        $parent_dir =~ s/(.+?)\\//;
        $parent_dir = reverse($parent_dir);
        $directory_id = $directory_id{$parent_dir};

        $name = reverse($file);
        $name =~ s/\\.*//;
        $name = reverse($name);

        $path_qt = $dbh->quote($file);
        $name_qt = $dbh->quote($name);


        if (!$fil_paths{$file}) {
                if(!($fil_id>0)){print "<br><font color=red>no id:$id</font>";exit;}
                $dbh->do("INSERT INTO $files_table SET id=$fil_id, directory_id=$directory_id, name=$name_qt, path=$path_qt");
                print "<br>$name";
        }

        $mp3 = MP3::Tag->new($file);
        $ext = $file;  $ext =~ s/.*\.//; $ext = lc($ext);
        if ($ext eq 'mp3' and $mp3 and !$fil_paths{$file}) {
                if ($title eq '-') {$title = ''}
                if ($track eq '-') {$track = ''}
                if ($artist eq '-') {$artist = ''}
                if ($album eq '-') {$album = ''}
                if ($comment eq '-') {$comment = ''}
                if ($year eq '-') {$year = ''}
                if ($genre eq '-') {$genre = ''}

                ($title, $track, $artist, $album, $comment, $year, $genre) = $mp3->autoinfo();
                ($title_qt, $track_qt, $artist_qt, $album_qt, $comment_qt, $year_qt, $genre_qt) =
                ($dbh->quote($title), $dbh->quote($track), $dbh->quote($artist), $dbh->quote($album), $dbh->quote($comment), $dbh->quote($year), $dbh->quote($genre));
                $dbh->do("INSERT INTO $mp3tags_table SET fil_id=$fil_id, title=$title_qt, track=$track_qt, artist=$artist_qt, album=$album_qt, comment=$comment_qt, year=$year_qt, genre=$genre_qt");
        }


        return File::DirWalk::SUCCESS;
});

foreach $dir_start (@dirs_start) {
        $dw->walk($dir_start);
}

print "<hr>FINISH";


###################################################
sub find_count_occur {
      local ($str, $substr)   = @_;
      local($count);
      $count = () = $str =~ /$substr/g;
      return $count;
}