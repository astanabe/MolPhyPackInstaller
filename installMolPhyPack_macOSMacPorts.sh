sudo -E port install gmake wget unzip gnutar xz zlib bzip2 autoconf automake coreutils ncurses readline openmpi openjdk8 || exit $?
if test -z $PREFIX; then
export PREFIX=/usr/local || exit $?
fi
# download , compile, and install Perl modules
if ! test -e .perlmodules; then
sudo -HE sh -c "yes '' | cpan -fi Statistics::Distributions Statistics::ChisqIndep Math::Random::MT" || exit $?
touch .perlmodules || exit $?
fi
# download, compile, and install EMBOSS
if ! test -e .emboss; then
wget -c ftp://emboss.open-bio.org/pub/EMBOSS/EMBOSS-6.6.0.tar.gz || exit $?
gnutar -xzf EMBOSS-6.6.0.tar.gz || exit $?
cd EMBOSS-6.6.0 || exit $?
sh ./configure --without-x --without-java --enable-static=no --prefix=$PREFIX || exit $?
gmake -j4 || exit $?
gmake install-strip || sudo gmake install-strip
cd .. || exit $?
rm -rf EMBOSS-6.6.0 EMBOSS-6.6.0.tar.gz || exit $?
touch .emboss || exit $?
fi
# download, compile, and install MAFFT
if ! test -e .mafft; then
wget -c https://mafft.cbrc.jp/alignment/software/mafft-7.475-without-extensions-src.tgz || exit $?
gnutar -xzf mafft-7.475-without-extensions-src.tgz || exit $?
cd mafft-7.475-without-extensions/core || exit $?
perl -i -npe 's/^CFLAGS *= */$& -mtune=native /' Makefile || exit $?
gmake PREFIX=$PREFIX -j4 || exit $?
gmake PREFIX=$PREFIX install || sudo gmake PREFIX=$PREFIX install || exit $?
cd ../.. || exit $?
rm -rf mafft-7.475-without-extensions mafft-7.475-without-extensions-src.tgz || exit $?
touch .mafft || exit $?
fi
# download, compile, and install PHYLIP
if ! test -e .phylip; then
wget -c http://evolution.gs.washington.edu/phylip/download/phylip-3.697.tar.gz || exit $?
gnutar -xzf phylip-3.697.tar.gz || exit $?
cd phylip-3.697/src || exit $?
perl -i -npe 's/^CFLAGS *= */$& -O3 -mtune=native /' Makefile.unx || exit $?
gmake -j4 -f Makefile.unx all || exit $?
gmake -f Makefile.unx install || exit $?
cd ../exe || exit $?
mkdir -p $PREFIX/bin || sudo mkdir -p $PREFIX/bin || exit $?
mv * $PREFIX/bin/ || sudo mv * $PREFIX/bin/ || exit $?
cd ../.. || exit $?
rm -rf phylip-3.697 phylip-3.697.tar.gz || exit $?
touch .phylip || exit $?
fi
# download, compile, and install ReadSeq
if ! test -e .readseq; then
wget -c -O readseq.jar https://sourceforge.net/projects/readseq/files/readseq/2.1.19/readseq.jar/download || exit $?
mkdir -p $PREFIX/bin || sudo mkdir -p $PREFIX/bin || exit $?
mv readseq.jar $PREFIX/bin/ || sudo mv readseq.jar $PREFIX/bin/ || exit $?
echo '#!/bin/sh' > readseq || exit $?
echo "java -Xms64m -Xmx8192m -jar $PREFIX/bin/readseq.jar \$*" >> readseq || exit $?
chmod 755 readseq || exit $?
mv readseq $PREFIX/bin/ || sudo mv readseq $PREFIX/bin/ || exit $?
touch .readseq || exit $?
fi
# download, compile, and install Primer3
if ! test -e .primer3; then
wget -c -O primer3-2.5.0.tar.gz https://github.com/primer3-org/primer3/archive/v2.5.0.tar.gz || exit $?
gnutar -xzf primer3-2.5.0.tar.gz || exit $?
cd primer3-2.5.0/src || exit $?
perl -i -npe 's/^O_OPTS *= */$& -mtune=native /' Makefile || exit $?
gmake -j4 || exit $?
mkdir -p $PREFIX/bin || sudo mkdir -p $PREFIX/bin || exit $?
mv long_seq_tm_test ntdpal ntthal oligotm primer3_core $PREFIX/bin/ || sudo mv long_seq_tm_test ntdpal ntthal oligotm primer3_core $PREFIX/bin/ || exit $?
cd ../.. || exit $?
rm -rf primer3-2.5.0.tar.gz primer3-2.5.0 || exit $?
touch .primer3 || exit $?
fi
# download, compile, and install RAxML
if ! test -e .raxml; then
wget -c -O RAxML-8.2.12.zip https://github.com/stamatak/standard-RAxML/archive/v8.2.12.zip || exit $?
unzip -qq RAxML-8.2.12.zip || exit $?
cd standard-RAxML-8.2.12 || exit $?
for f in Makefile.*; do perl -i -npe 's/^CFLAGS *= */$& -march=core2 /;s/ -march=native//' $f || exit $?; done
perl -i -npe "s/-march=core2/-march=corei7-avx/" Makefile.AVX.gcc || exit $?
perl -i -npe "s/-march=core2/-march=corei7-avx/" Makefile.AVX.PTHREADS.gcc || exit $?
perl -i -npe "s/-march=core2/-march=core-avx2/" Makefile.AVX2.gcc || exit $?
perl -i -npe "s/-march=core2/-march=core-avx2/" Makefile.AVX2.PTHREADS.gcc || exit $?
perl -i -npe "s/-D_FMA/$& -mfma/" Makefile.AVX2.gcc || exit $?
perl -i -npe "s/-D_FMA/$& -mfma/" Makefile.AVX2.PTHREADS.gcc || exit $?
gmake -j4 -f Makefile.gcc || exit $?
mv raxmlHPC $PREFIX/bin/ || sudo mv raxmlHPC $PREFIX/bin/ || exit $?
gmake -f Makefile.gcc clean || exit $?
gmake -j4 -f Makefile.PTHREADS.gcc || exit $?
mv raxmlHPC-PTHREADS $PREFIX/bin/ || sudo mv raxmlHPC-PTHREADS $PREFIX/bin/ || exit $?
gmake -f Makefile.PTHREADS.gcc clean || exit $?
gmake -j4 -f Makefile.AVX.gcc || exit $?
mv raxmlHPC-AVX $PREFIX/bin/ || sudo mv raxmlHPC-AVX $PREFIX/bin/ || exit $?
gmake -f Makefile.AVX.gcc clean || exit $?
gmake -j4 -f Makefile.AVX.PTHREADS.gcc || exit $?
mv raxmlHPC-PTHREADS-AVX $PREFIX/bin/ || sudo mv raxmlHPC-PTHREADS-AVX $PREFIX/bin/ || exit $?
gmake -f Makefile.AVX.PTHREADS.gcc clean || exit $?
gmake -j4 -f Makefile.AVX2.gcc || exit $?
mv raxmlHPC-AVX2 $PREFIX/bin/ || sudo mv raxmlHPC-AVX2 $PREFIX/bin/ || exit $?
gmake -f Makefile.AVX2.gcc clean || exit $?
gmake -j4 -f Makefile.AVX2.PTHREADS.gcc || exit $?
mv raxmlHPC-PTHREADS-AVX2 $PREFIX/bin/ || sudo mv raxmlHPC-PTHREADS-AVX2 $PREFIX/bin/ || exit $?
gmake -f Makefile.AVX2.PTHREADS.gcc clean || exit $?
gmake -j4 -f Makefile.SSE3.gcc || exit $?
mv raxmlHPC-SSE3 $PREFIX/bin/ || sudo mv raxmlHPC-SSE3 $PREFIX/bin/ || exit $?
gmake -f Makefile.SSE3.gcc clean || exit $?
gmake -j4 -f Makefile.SSE3.PTHREADS.gcc || exit $?
mv raxmlHPC-PTHREADS-SSE3 $PREFIX/bin/ || sudo mv raxmlHPC-PTHREADS-SSE3 $PREFIX/bin/ || exit $?
gmake -f Makefile.SSE3.PTHREADS.gcc clean || exit $?
cd .. || exit $?
rm -rf RAxML-8.2.12.zip standard-RAxML-8.2.12 || exit $?
touch .raxml || exit $?
fi
# download, compile, and install trimAl
if ! test -e .trimal; then
wget -c -O trimal-1.4.1.tar.gz https://github.com/scapella/trimal/archive/v1.4.1.tar.gz || exit $?
gnutar -xzf trimal-1.4.1.tar.gz || exit $?
cd trimal-1.4.1/source || exit $?
perl -i -npe 's/^FLAGS *= */$&-O2 -mtune=native /' makefile || exit $?
gmake -f makefile -j4 || exit $?
mv readal trimal statal $PREFIX/bin/ || sudo mv readal trimal statal $PREFIX/bin/ || exit $?
cd ../.. || exit $?
rm -rf trimal-1.4.1 trimal-1.4.1.tar.gz || exit $?
touch .trimal || exit $?
fi
# download, compile, and install CONSEL
if ! test -e .consel; then
wget -c http://stat.sys.i.kyoto-u.ac.jp/prog/consel/pub/cnsls020.tgz || exit $?
gnutar -xf cnsls020.tgz || exit $?
cd consel/src || exit $?
perl -i -npe 's/^(CFLAGS *= *)\-g */$1-O2 -mtune=native /' Makefile || exit $?
gmake -j4 || exit $?
gmake install || exit $?
cd ../bin || exit $?
mv * $PREFIX/bin/ || sudo mv * $PREFIX/bin/ || exit $?
cd ../.. || exit $?
rm -rf cnsls020.tgz consel || exit $?
touch .consel || exit $?
fi
# download, compile, and install MrBayes5D
if ! test -e .mrbayes5d; then
wget -c https://www.fifthdimension.jp/products/mrbayes5d/mrbayes5d-3.2.6.2016.11.02.zip || exit $?
unzip -qq mrbayes5d-3.2.6.2016.11.02.zip || exit $?
cd mrbayes5d-3.2.6.2016.11.02/src || exit $?
sh ./configure --enable-debug=no --enable-mpi=no --enable-sse=yes --enable-threads=no --without-beagle --prefix=$PREFIX || exit $?
gmake -j4 || exit $?
gmake install || sudo gmake install || exit $?
gmake distclean || exit $?
mpicc=mpicc-openmpi-mp sh ./configure --enable-debug=no --enable-mpi=yes --enable-sse=yes --enable-threads=no --without-beagle --prefix=$PREFIX || exit $?
gmake CC=mpicc-openmpi-mp -j4 || exit $?
cp mrbayes5d $PREFIX/bin/mrbayes5d-mpi || sudo cp mrbayes5d $PREFIX/bin/mrbayes5d-mpi || exit $?
cd ../.. || exit $?
rm -rf mrbayes5d-3.2.6.2016.11.02.zip mrbayes5d-3.2.6.2016.11.02 || exit $?
touch .mrbayes5d || exit $?
fi
# download, and install FigTree
if ! test -e .figtree; then
wget -c https://github.com/rambaut/figtree/releases/download/v1.4.4/FigTree_v1.4.4.tgz || exit $?
gnutar -xzf FigTree_v1.4.4.tgz || exit $?
cd FigTree_v1.4.4/lib || exit $?
mkdir -p $PREFIX/share/figtree || sudo mkdir -p $PREFIX/share/figtree || exit $?
mv figtree.jar $PREFIX/share/figtree/ || sudo mv figtree.jar $PREFIX/share/figtree/ || exit $?
cd ../bin || exit $?
echo '#!/bin/sh' > figtree || exit $?
echo "java -Xms64m -Xmx8192m -jar $PREFIX/share/figtree/figtree.jar \$*" >> figtree || exit $?
chmod 755 figtree || exit $?
mv figtree $PREFIX/bin/ || sudo mv figtree $PREFIX/bin/ || exit $?
cd ../.. || exit $?
rm -rf FigTree_v1.4.4.tgz FigTree_v1.4.4 || exit $?
touch .figtree || exit $?
fi
# download, and install Tracer
if ! test -e .tracer; then
wget -c https://github.com/beast-dev/tracer/releases/download/v1.7.1/Tracer_v1.7.1.tgz || exit $?
gnutar -xzf Tracer_v1.7.1.tgz || exit $?
cd Tracer_v1.7.1/lib || exit $?
mkdir -p $PREFIX/share/tracer || sudo mkdir -p $PREFIX/share/tracer || exit $?
mv *.jar $PREFIX/share/tracer/ || sudo mv *.jar $PREFIX/share/tracer/ || exit $?
cd ../bin || exit $?
echo '#!/bin/sh' > tracer || exit $?
echo "TRACER_LIB=$PREFIX/share/tracer" >> tracer || exit $?
echo "java -Xms64m -Xmx8192m -jar $PREFIX/share/tracer/tracer.jar \$*" >> tracer || exit $?
chmod 755 tracer || exit $?
mv tracer $PREFIX/bin/ || sudo mv tracer $PREFIX/bin/ || exit $?
cd ../.. || exit $?
rm -rf Tracer_v1.7.1.tgz Tracer_v1.7.1 || exit $?
touch .tracer || exit $?
fi
# download, compile, and install Kakusan4
if ! test -e .kakusan4; then
wget -c https://www.fifthdimension.jp/products/kakusan/kakusan4-4.0.2016.11.07.zip || exit $?
unzip -qq kakusan4-4.0.2016.11.07.zip || exit $?
cd kakusan4-4.0.2016.11.07 || exit $?
perl -i -npe 's/^CFLAGS *= */$&-mtune=native /;s/ -frerun-loop-opt//;s/ -static-libgcc//' Makefile.UNIX || exit $?
gmake -j4 -f Makefile.UNIX || exit $?
mkdir -p $PREFIX/share/kakusan4 || sudo mkdir -p $PREFIX/share/kakusan4 || exit $?
mv kakusan4.pl baseml $PREFIX/share/kakusan4/ || sudo mv kakusan4.pl baseml $PREFIX/share/kakusan4/ || exit $?
echo '#!/bin/sh' > kakusan4 || exit $?
echo "perl $PREFIX/share/kakusan4/kakusan4.pl \$*" >> kakusan4 || exit $?
chmod 755 kakusan4 || exit $?
mv kakusan4 $PREFIX/bin/ || sudo mv kakusan4 $PREFIX/bin/ || exit $?
cd .. || exit $?
rm -rf kakusan4-4.0.2016.11.07.zip kakusan4-4.0.2016.11.07 || exit $?
touch .kakusan4 || exit $?
fi
# download, compile, and install Aminosan
if ! test -e .aminosan; then
wget -c https://www.fifthdimension.jp/products/aminosan/aminosan-1.0.2016.11.07.zip || exit $?
unzip -qq aminosan-1.0.2016.11.07.zip || exit $?
cd aminosan-1.0.2016.11.07 || exit $?
perl -i -npe 's/^CFLAGS *= */$&-mtune=native /;s/ -frerun-loop-opt//;s/ -static-libgcc//' Makefile.UNIX || exit $?
gmake -j4 -f Makefile.UNIX || exit $?
mkdir -p $PREFIX/share/aminosan || sudo mkdir -p $PREFIX/share/aminosan || exit $?
mv aminosan.pl codeml $PREFIX/share/aminosan/ || sudo mv aminosan.pl codeml $PREFIX/share/aminosan/ || exit $?
echo '#!/bin/sh' > aminosan || exit $?
echo "perl $PREFIX/share/aminosan/aminosan.pl \$*" >> aminosan || exit $?
chmod 755 aminosan || exit $?
mv aminosan $PREFIX/bin/ || sudo mv aminosan $PREFIX/bin/ || exit $?
cd .. || exit $?
rm -rf aminosan-1.0.2016.11.07.zip aminosan-1.0.2016.11.07 || exit $?
touch .aminosan || exit $?
fi
# download, and install Phylogears2
if ! test -e .phylogears2; then
wget -c -O Phylogears-2.0.2020.05.06.zip https://github.com/astanabe/Phylogears/archive/v2.0.2020.05.06.zip || exit $?
unzip -qq Phylogears-2.0.2020.05.06.zip || exit $?
cd Phylogears-2.0.2020.05.06 || exit $?
gmake PREFIX=$PREFIX -j4 || exit $?
gmake PREFIX=$PREFIX install || sudo gmake PREFIX=$PREFIX install || exit $?
cd .. || exit $?
rm -rf Phylogears-2.0.2020.05.06.zip Phylogears-2.0.2020.05.06 || exit $?
touch .phylogears2 || exit $?
fi
echo 'Installation finished correctly!'
echo "You might need to add \"$PREFIX\" to PATH environment variable."
