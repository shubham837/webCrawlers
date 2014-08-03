# Define module to use
use HTML::Parser();
# Create instance
$p = HTML::Parser->new(start_h => [\&start_rtn, 'tag'],
                text_h => [\&text_rtn, 'text'],
                end_h => [\&end_rtn, 'tag']);
# Start parsing the following HTML string
$p->parse('
<HTML>
<HEAD>
<TITLE>Sample HTML Page</TITLE>
</HEAD>
<BODY>
Hello World
This is a test
</BODY>
</HTML>');

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
