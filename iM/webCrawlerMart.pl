require LWP::UserAgent;

$bandname = "Metallica";
getartistinfo($bandname);

sub getartistinfo {
  my %formdata;
  my $ua = LWP::UserAgent->new;
  #~ $ua->proxy('http','http://[PROXY_URL]:[PROXY_PORT]/');

  $formdata{'sql'}=$_[0];
  $formdata{'opt1'}=1;
  $formdata{'P'}='amg';

  print "Sending HTTP request for ".$_[0]."...\n";
  my $response = $ua->post('http://www.allmusic.com/cg/amg.dll',\%formdata);

  if ($response->is_success) {
    print "Got HTTP response... parsing output for ".$_[0]."...\n\n";
    $output=$response->content;

    # Extracting Overview, Biography, Discography, Songs, Credit, Charts & Awards link for the artist
    $output =~ m/cg\/amg.dll\?p\=amg\&searchlink\=(.*)\">/;
    $BaseLink = "http://www.allmusic.com/cg/amg.dll?p=amg&searchlink=";
    $OverviewLink = $1;
    $DiscographyMainAlbumLink = $BaseLink.$OverviewLink;
    $DiscographyMainAlbumLink =~ s/T0/T20/;
    print "Discography Main Album: ".$DiscographyMainAlbumLink."\n";
    $DiscographySinglesEPLink = $BaseLink.$OverviewLink;
    $DiscographySinglesEPLink =~ s/T0/T22/;
    print "Discography Singles&EP: ".$DiscographySinglesEPLink."\n";
    $DiscographyDvDVideosLink = $BaseLink.$OverviewLink;
    $DiscographyDvDVideosLink =~ s/T0/T23/;
    print "Discography DVD Videos: ".$DiscographyDvDVideosLink."\n";
    $DiscographyAllSongsLink = $BaseLink.$OverviewLink;
    $DiscographyAllSongsLink =~ s/T0/T31/;
    print "Songs All Songs: ".$DiscographyAllSongsLink."\n";
    $DiscographyCnAAlbumsLink = $BaseLink.$OverviewLink;
    $DiscographyCnAAlbumsLink =~ s/T0/T50/;
    print "Charts & Awards Billboard Albums: ".$DiscographyCnAAlbumsLink."\n";
    $DiscographyCnASinglesLink = $BaseLink.$OverviewLink;
    $DiscographyCnASinglesLink =~ s/T0/T51/;
    print "Charts & Awards Billboard Singles: ".$DiscographyCnASinglesLink."\n";
    $DiscographyGrammyLink = $BaseLink.$OverviewLink;
    $DiscographyGrammyLink =~ s/T0/T52/;
    print "Charts & Awards Grammy Awards: ".$DiscographyGrammyLink."\n\n";

    # Extracting Title Bar
    $output =~ m/<td class=\"titlebar\"><span class=\"title\">(.*)<\/span><br \/>/;
    $titlebar = $1;
    print "Titlebar:\n".$titlebar."\n\n";
    $output = $';

    # Extracting Formed-Sub
    $output =~ m/Begin Formed(.*)<span>(.*)End Formed/;
    $output = $';
    $formedsub = $2;
    $formedsub =~ m/<a href=(.*)>(.*)<\/a>(.*)<a href=(.*)>(.*?)<\/a>/; # Parse $formedsub for exact string
    print "Formed: ".$2.$3.$5."\n\n";

    # Extracting timelinesubactive
    while($output =~ m/class=\"timeline-sub-active\">(\d+)<\/div>/) {
      print "ActiveYear:".$1."\n";
      $output = $';
    }
    print "\n";

    # Extract Genre, Style titles
    $output =~ m/id=\"left-sidebar-title-small\"(.*?)<\/tr>/;
    $suboutput = $&;
    $output = $';
    while($suboutput =~ m/id=\"left-sidebar-title-small\"><span>(.*?)<\/span>/) {
      #~ print "Subclasses:".$1."\n";
      push(@GSM,$1);
      $suboutput = $';
    }
    #~ print "\n";

    # Extract Genre contents
    $output =~ m/<td class=\"list-cell\"(.*?)<\/td>/;
    $suboutput = $&;
    $output = $';
    while($suboutput =~ m/<li>(.*?)<\/li>/) {
      #~ print "Genres:".$1."\n";
      $suboutput = $';
      $1 =~ m/<a href=(.*)>(.*)<\/a>/;
      push(@G,$2);
    }
    #~ print "\n";

    # Extract Style contents
    $output =~ m/<td class=\"list-cell\"(.*?)<\/td>/;
    $suboutput = $&;
    $output = $';
    while($suboutput =~ m/<li>(.*?)<\/li>/) {
      #~ print "Styles:".$1."\n";
      $suboutput = $';
      $1 =~ m/<a href=(.*)>(.*)<\/a>/;
      push(@S,$2);
    }
    #~ print "\n";

    # Extract Mood subclass
    $output =~ m/id=\"left-sidebar-title-small\"><span>(.*?)<\/span>/;
    $output = $';
    #~ print "Subclasses:".$1."\n\n";
    push(@GSM,$1);

    # Extract Mood Contents
    $output =~ m/id=\"left-sidebar-list\"(.*?)<\/div>/;
    $suboutput = $&;
    $output = $';
    while($suboutput =~ m/<li>(.*?)<\/li>/) {
      #~ print "Moods:".$1."\n";
      $suboutput = $';
      $1 =~ m/<a href=(.*)>(.*)<\/a>/;
      push(@M,$2);
    }
    print "\n";

    # Print the @GSM and @G,@S,@M content
    print $GSM[0].":";
    foreach $gen (@G) {
      print $gen."\t";
    }
    print "\n\n".$GSM[1].":";
    foreach $gen (@S) {
      print $gen."\t";
    }
    print "\n\n".$GSM[2].":";
    foreach $gen (@M) {
      print $gen."\t";
    }
    print "\n\n";

    # Extract AMG Artist ID
    $output =~ m/<td class=\"sub-text\"(.*?)<\/pre>/;
    $output = $';
    $1 =~ m/<pre>(.*)/;
    print "AMG Artist ID:".$1."\n\n";

    # Extracting Artist Mini Bio
    $output =~ m/id=\"artistminibio\"><p>(.*)<\/p>/;
    $artistminibio = $1;
    $artistminibio =~ s/<a href(.*?)>//g; # Filtering out any link or html tags
    $artistminibio =~ s/<\/a>//g;
    $artistminibio =~ s/<i>//g;
    $artistminibio =~ s/<\/i>//g;
    print "ArtistMiniBio:\n".$artistminibio."\n\n";

    # Extracting Other Entries, Group Members, Similar Artists, Influenced By and Follower
    $output =~ m/id=\"large-list\"><tr>(.*?)<\/table>/;
    $suboutput = $&;
    $output = $';
    # Extracting two part of the table
    $suboutput =~ m/<td valign=\"top\" width=\"266px\">(.*)<\/td><td/;
    $lefthalftemp = $1;
    $righthalftemp = $';

    while($lefthalftemp =~ m/<div class=\"large-list-subtitle\">(.*?)<\/div>/) {
      print $1.":\n";
      $' =~ m/<ul>(.*?)<\/ul>/;
      $lefthalftemp = $';
      $li = $1;
      while($li =~ m/<li>(.*?)<\/li>/) {
        $li = $';
        $1 =~ m/<span class=\"libg\"><a href=(.*)>(.*)<\/a><\/span>/i;
        print $2."\n";
      }
      print "\n\n";
    }

    while($righthalftemp =~ m/<div class=\"large-list-subtitle\">(.*?)<\/div>/) {
      print $1.":\n";
      $' =~ m/<ul>(.*?)<\/ul>/;
      $righthalftemp = $';
      $li = $1;
      while($li =~ m/<li>(.*?)<\/li>/) {
        $li = $';
        $1 =~ m/<span class=\"libg\"><a href=(.*)>(.*)<\/a><\/span>/i;
        print $2."\n";
      }
      print "\n\n";
    }
  }
}
