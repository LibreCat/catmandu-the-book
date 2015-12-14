.PHONY: wiki local distributions.json

# download all Catmandu distributions from CPAN
download: distributions.json

# collect information about all Catmandu distributions
distributions.json:
	perl -Ilocal/lib/perl5 distributions.pl
 
# Extract list of modules from distributions
modules: modules.json
modules.json:
	perl -Ilocal/lib/perl5 modules.pl

# clone Catmandu Wiki
wiki:
	git -C wiki pull || git clone https://github.com/LibreCat/Catmandu.wiki.git wiki

# install missing modules to local/
local:
	cpanm -l local --skip-satisfied --installdeps .

overview:
	perl -Ilocal/lib/perl5 overview.pl | \
		pandoc -f json -o overview.html -s --toc
