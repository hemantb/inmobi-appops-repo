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
		my $count = `ls -1 $CONF_DIR/lb_haproxy.d/$list | wc -l`;
		chomp $count; next if ! $count;
		$list =~ s/\s+$//;
		$list =~ s/^\s+//;
		if ($list =~ /^(sticky|notsticky|nosticky)-(http|tcp)-(\d+)-(.+)-(\d+)$/) {
			$VHOSTS{$3}{$list}{sticky} = $1;
			$VHOSTS{$3}{$list}{mode} = $2;
			$VHOSTS{$3}{$list}{vhost} = $4;
			$VHOSTS{$3}{$list}{dest} = $5;
		} else {
			print STDERR "$list is not in valid format\n";
		}
	}
}

foreach my $fport (keys %VHOSTS) {

	foreach my $vhost (keys %{$VHOSTS{$fport}}) {
		my ($acl, $backend);

		$LISTEN .= "listen $vhost *:$fport\n\n";
		$LISTEN .= "        balance roundrobin\n";
		$LISTEN .= "        mode $VHOSTS{$fport}{$vhost}{mode}\n\n";
		$LISTEN .= "        cookie SERVERID insert indirect nocache\n";
		$LISTEN .= "        appsession JSESSIONID len 100 timeout 7d\n" if $VHOSTS{$fport}{$vhost}{sticky} eq 'sticky';
                 
		open (FILE, "$CONF_DIR/lb_haproxy.d/${vhost}.cfg") || die "Can't open config file $CONF_DIR/lb_haproxy.d/${vhost}.cfg";

                foreach my $line (<FILE>) {
			$line =~ s/\s+$//;
			$line =~ s/^\s+//;
			next if $line !~ /^([^=]+)=([^=]+)$/;
                        $listencont{$1} = $2;
                }
		close FILE;

                $LISTEN .= "$listencont{status_uri}\n" if $listencont{status_uri};
                $LISTEN .= "$listencont{health_uri}\n" if $listencont{health_uri};
                $LISTEN .= "$listencont{health_check_line}\n" if $listencont{health_check_line} and $listencont{health_uri};
                $ILSTEN .= "\n\n";

		$LISTEN .= "        server disabled-server 127.0.0.1:1 check downinter 2000d\n";

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
			$LISTEN .= "        server $contents{server} $contents{backend_ip}:$VHOSTS{$fport}{$vhost}{dest} ";
			$LISTEN .= "cookie $contents{server} ";
			$LISTEN .= "check " if $contents{health_check_uri};
			$LISTEN .= "$content{stickyness} " if $contents{stickyness};
			$LISTEN .= "$contents{extraopts} " if $contents{extraopts};
			$LISTEN .= "maxconn $contents{maxconn}" if $contents{maxconn};
			$LISTEN .= "\n\n";
		}
	}
}
			
open(FILE, ">$CONF_FILE") || die "Couldnt write to config file $CONF_FILE";

print FILE $HEAD;
print FILE $LISTEN;

print $HEAD;
print $LISTEN;

close FILE;

