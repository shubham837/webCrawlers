#!/usr/bin/perl
use strict;	
use warnings;


#use HTML::Parser();
#use HTML::TreeBuilder;
#my $p = HTML::Parser->new(start_h => [\&start_rtn, 'tag'],
#               text_h => [\&text_rtn, 'text'],
#              end_h => [\&end_rtn, 'tag']);


#Now we will define variables, “links” is the list we are using. “cur_link” is the link of current page
my(@links,$cur_link,$pageContent);
push(@links,"http://www.indiamart.com/");


#argument is link
sub extractAllLinks {

	# in the next few lines, we run the system command “curl” and retrieve the page content
        open my $fh,"curl $_[0]|";
        {
                local $/;
                $pageContent=<$fh>;
        }
        close $fh;
#        print "\nCurrently Scanning -- ".$_[0];
	return $pageContent;
}

foreach $cur_link (@links)
{
        if($cur_link=~/^http/)
        {
	 	# In the next line we extract all links in the first page
	        my $var = extractAllLinks($cur_link);	
                my @productIndustryLinks; 		#= $var=~/<a href=\"http:\/\/dir.indiamart.com\/industry\/(.*?)\">/g;
		my @productIndustryName; 		#= $var=~/<a href=\"http:\/\/dir.indiamart.com\/industry\/.*>(.*?)<\/a>/g;
    		while($var =~ m/<a href=\"http:\/\/dir.indiamart.com\/industry\/(.*?)\">\n*?(.*?)\n*?<\/a>/) {
			push(@productIndustryLinks,$1);
			push(@productIndustryName,$2);
      			$var = $';
    		}
		my $count=0;
                foreach my $industryLink (@productIndustryLinks) 
                {       
			$industryLink="http:\/\/dir.indiamart.com\/industry\/".$industryLink;
		        print "IndustryName: ", $productIndustryName[$count], "\n----------------------\n----------------------\n-----------------------\n";
			
			#Content of 2nd page or Industry page
			my $var= extractAllLinks($industryLink);

                        my @productLinks; 			#= $var=~/<a.*href=\"\/impcat\/(.*?)\"/g;
			my @productTypes; 			#= $var=~/<a.*href=\"\/impcat\/.*\".*>(.*?)<\/a>.*<br/g;
			while($var =~ m/<a.*href="\/impcat\/(.*?)\".*>(.*?)<\/a>.*<br/) {
                        	push(@productLinks,$1);
                        	push(@productTypes,$2);
                        	$var = $';
                	}
			my $count2=0;
			foreach my $productLink (@productLinks) {
				
				$productLink="http:\/\/dir.indiamart.com\/impcat\/".$productLink;
				print "Product Type: ", $productTypes[$count2], "\n---------------------\n----------------------\n";
				
				#content on final page

				my $var= extractAllLinks($productLink);
#my $root = HTML::TreeBuilder->new_from_content($var);
#$p->parse($var);
				my @productNames= $var=~/<a class=\"product-name\".*?>(.*?)<\/a>/g;           #$var=~/<a class=\"product-name".*?>(.*?)<\/a>/g;
				#my @productDescriptions=  $var=~/<p.id=\"trimmed_desc.".class="description-clr description-padding\">\n*(.*)\n*.*\n*.*\n*.*\n*.*\n*.*\n*.*\n*.*<\/p>/g; 
#$root->find_by_attribute("class","description-clr description-padding");
				my @sellerName =  $var=~/<span itemprop=\"name\">\n*(.*?)\n*<\/span>/g; 
#$root->find_by_attribute("class","company-name");
				my @telephoneNumber = $var=~/<span itemprop=\"telephone\">\n*(.*?)\n*<\/span>/g;
				my @streetAddress = $var=~/<span itemprop=\"streetAddress\">\n*(.*?)\n*<\/span>/g;
				my @city = $var=~/<span.*?itemprop=\"addressLocality\">\n*?(.*?)\n*?<\/span>/g;
				my $count3=0;
				foreach my $productName (@productNames) {
					print "ProductName: ", $productName, "\n";
				#	print "ProductDescription: ", $productDescriptions[$count3], "\n";
					print "SellerName: ", $sellerName[$count3], "\n";
					print "TelephoneNumber: ", $telephoneNumber[$count3], "\n";
					print "StreetAddress: ", $streetAddress[$count3], "\n";
					print "City: ", $city[$count3], "\n-----------------\n";
					++$count3;
				}	
				++$count2;
							
			} 
			++$count;
		}
			
		# In the next line we add the links to the main “links” list.
 		#push(@links,$temp);
		#print $temp, "\n";
        }
}

sub start_rtn {
# Execute when start tag is encountered
    foreach (@_) {
       print "===\nStart: $_\n";
    }
}
sub text_rtn {
# Execute when text is encountered
    foreach (@_) {
       print "\tText: $_\n";
    }
}
sub end_rtn {
# Execute when the end tag is encountered
    foreach (@_) {
       print "End: $_\n";
    }
}
