#! /usr/bin/perl

$CONF_FILE="/opt/mkhoj/conf/lb/inmobi_lb.cfg";
$CONF_DIR="/opt/mkhoj/conf/lb";

open(FILE, "$CONF_DIR/inmobi_lb.cfg.head") || die "Can't open config file";
$HEAD = join("", <FILE>);
close FILE;

@dirlist = `ls -1 $CONF_DIR/lb_haproxy.d`;

foreach my $list (@dirlist) {
	chomp $list;
	if (-d "$CONF_DIR/lb_haproxy.d/$list" && -f "$CONF_DIR/lb_haproxy.d/${list}.cfg") {
		print "pushing $list\n";
		my $count = `ls -1 $CONF_DIR/lb_haproxy.d/$list | wc -l`;
		chomp $count; next if ! $count;
		$list =~ s/\s+$//;
		$list =~ s/^\s+//;
		if ($list =~ /^(sticky|notsticky|nosticky)-(\d+)-(.+)-(\d+)$/) {
			$VHOSTS{$2}{$list}{sticky} = $1;
			$VHOSTS{$2}{$list}{dest} = $4;
			$VHOSTS{$2}{$list}{vhost} = $3;
		} else {
			print STDERR "$list is not in valid format\n";
		}
	}
}

foreach my $fport (keys %VHOSTS) {
	$FRONTEND .= "frontend ${fport}_requests *:$fport\n\n";
	foreach my $vhost (keys %{$VHOSTS{$fport}}) {
		my ($acl, $backend);
		$acl = $backend = $vhost;
		$acl =~ s/\./_/g;
		$backend =~ s/\./_/g;
		$FRONTEND .= "        acl ${acl}_acl hdr_dom(host) -i $VHOSTS{$fport}{$vhost}{vhost}\n";
		$FRONTEND .= "        use_backend ${backend}_backend if ${acl}_acl\n\n";

		open (FILE, "$CONF_DIR/lb_haproxy.d/${vhost}.cfg") || die "Can't open config file $CONF_DIR/lb_haproxy.d/${vhost}.cfg";
		$BACKEND .= join("", <FILE>);
		close FILE;

		my @hostlist = `find $CONF_DIR/lb_haproxy.d/$vhost -type f`;
		foreach my $bhost (@hostlist) {
			open (FILE, "$bhost") || die "Couldn't open config file $bhost";
			foreach my $line (<FILE>) {
				chomp $line;
				$line =~ s/\s+$//;
				$line =~ s/^\s+$//;
				next if $line !~ /^([^=]+)=(.+)$/;
				$contents{$1} = $2;
			}
			close FILE;
			$BACKEND .= "        server $contents{server} $contents{backend_ip}:$VHOSTS{$fport}{$vhost}{dest} ";
			$BACKEND .= "cookie $contents{server} " if $contents{stickyness} eq 'sticky';
			$BACKEND .= "check " if $contents{health_check_uri};
			$BACKEND .= "$contents{extraopts} " if $contents{extraopts};
			$BACKEND .= "maxconn $contents{maxconn}" if $contents{maxconn};
			$BACKEND .= "\n\n"
		}
	}
}
			
open(FILE, ">$CONF_FILE") || die "Couldnt write to config file $CONF_FILE";

print FILE $HEAD;
print FILE $FRONTEND;
print FILE $BACKEND;

close FILE;
