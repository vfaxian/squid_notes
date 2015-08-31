#!/usr/bin/perl

#############################################
#                                           #
#  c2d-squid-redirect.pl                    #
#                                           #
#  required modules/packages:               #
#  LWP::Simple : libwww-perl                #
#  Tie::Cache  : libtie-cache-perl          #
#                                           #
#############################################
use LWP::UserAgent;
use Tie::Cache;
use strict;

# The top-most URL should always be the local proxy service,
# but after that the URLs should be listed in proximity order.
# Remove the local site from the list to further avoid the
# risk of a redirect loop.
use constant PROXY_SOURCE_URLS => [
  "http://sw-cache.yourdomain.net",
  "http://swrepo-jpto.yourdomain.net",
  "http://swrepo.yourdomain.net",
  "http://cda-front.yourdomain.net",
];

# URLs to match and redirect to in correct order. The hash keys
# must match the possible hostnames of the redirect action, i.e.
# what's returned by the c2d-redirect script run by Apache in
# response to a 404.
my %urlMap = (
  "http://cnbjlx9455" => PROXY_SOURCE_URLS,
);

#------------------------------------------
$| = 1;
my %cache;
tie %cache, 'Tie::Cache', { MaxCount => 50000, Debug => 0};
my $ua = LWP::UserAgent->new(max_redirect => 0);

# Read from STDIN
while (<>) {
  my $mapped = 0;
  my @elems = split;    # splits on whitespace by default

  # The URL is the first whitespace-separated element.
  my $url = $elems[0];

  if ($url =~m#^(http://[^/]+)(/.*)#) {
    my $server = $1;
    my $path = $2;

    if ($path eq '/clear-squid-redirect-cache/') {
      %cache = ();
    } elsif (exists $urlMap{$server}) {
      if (my $cachedUrl = $cache{$url}) {
        # Redirected URL from cache
        print "$cachedUrl\n";
        $mapped++;
      } else {
        foreach my $redirect (@{$urlMap{$server}}) {
          if ( $ua->head( $redirect . $path )->is_success() ) {
            # Redirected URL
            print "$redirect$path\n";
            # Add to cache
            $cache{$url} = $redirect . $path;
            $mapped++;
            last;
          }
        }
      }
    }
  }

  # Unmodified URL
  print "$url\n" unless $mapped;
}
