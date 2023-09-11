sudo dnf install gcc gcc-c++ make wget tar gzip bzip2 xz unzip coreutils perl ca-certificates ncurses ncurses-devel readline readline-devel openmpi openmpi-devel || exit $?
export PATH=$PATH:/usr/lib64/openmpi/bin
if test -z $PREFIX; then
export PREFIX=/usr/local || exit $?
fi
# download and install JRE11
if ! test -e .java; then
wget -c https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.20.1%2B1/OpenJDK11U-jre_x64_linux_hotspot_11.0.20.1_1.tar.gz || exit $?
tar -xzf OpenJDK11U-jre_x64_linux_hotspot_11.0.20.1_1.tar.gz || exit $?
mkdir -p $PREFIX/share/molphypack || sudo mkdir -p $PREFIX/share/molphypack || exit $?
mv jdk-11.0.20.1+1-jre/* $PREFIX/share/molphypack/ || sudo mv jdk-11.0.20.1+1-jre/* $PREFIX/share/molphypack/ || exit $?
rm -rf jdk-11.0.20.1+1-jre OpenJDK11U-jre_x64_linux_hotspot_11.0.20.1_1.tar.gz || exit $?
touch .java || exit $?
fi
# download , compile, and install Perl modules
if ! test -e .perlmodules; then
sudo -HE sh -c "yes '' | cpan -fi Statistics::Distributions Statistics::ChisqIndep Math::Random::MT" || exit $?
touch .perlmodules || exit $?
fi
# download, compile, and install EMBOSS
if ! test -e .emboss; then
wget -c ftp://emboss.open-bio.org/pub/EMBOSS/EMBOSS-6.6.0.tar.gz || exit $?
tar -xzf EMBOSS-6.6.0.tar.gz || exit $?
cd EMBOSS-6.6.0 || exit $?
sh ./configure --without-x --without-java --enable-static=no --prefix=$PREFIX || exit $?
make -j4 || exit $?
make install-strip || sudo make install-strip
ldconfig || sudo ldconfig || exit $?
cd .. || exit $?
rm -rf EMBOSS-6.6.0 EMBOSS-6.6.0.tar.gz || exit $?
touch .emboss || exit $?
fi
# download, compile, and install MAFFT
if ! test -e .mafft; then
wget -c https://mafft.cbrc.jp/alignment/software/mafft-7.505-without-extensions-src.tgz || exit $?
tar -xzf mafft-7.505-without-extensions-src.tgz || exit $?
cd mafft-7.505-without-extensions/core || exit $?
perl -i -npe 's/^CFLAGS *= */$& -mtune=native /' Makefile || exit $?
make PREFIX=$PREFIX -j4 || exit $?
make PREFIX=$PREFIX install || sudo make PREFIX=$PREFIX install || exit $?
cd ../.. || exit $?
rm -rf mafft-7.505-without-extensions mafft-7.505-without-extensions-src.tgz || exit $?
touch .mafft || exit $?
fi
# download, compile, and install PHYLIP
if ! test -e .phylip; then
wget -c http://evolution.gs.washington.edu/phylip/download/phylip-3.697.tar.gz || exit $?
tar -xzf phylip-3.697.tar.gz || exit $?
cd phylip-3.697/src || exit $?
perl -i -npe 's/^CFLAGS *= */$& -O3 -mtune=native -fcommon /' Makefile.unx || exit $?
make -j4 -f Makefile.unx all || exit $?
make -f Makefile.unx install || exit $?
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
echo "$PREFIX/share/molphypack/bin/java -Xms64m -Xmx8192m -jar $PREFIX/bin/readseq.jar \$*" >> readseq || exit $?
chmod 755 readseq || exit $?
mv readseq $PREFIX/bin/ || sudo mv readseq $PREFIX/bin/ || exit $?
touch .readseq || exit $?
fi
# download, compile, and install Primer3
if ! test -e .primer3; then
wget -c -O primer3-2.6.1.tar.gz https://github.com/primer3-org/primer3/archive/refs/tags/v2.6.1.tar.gz || exit $?
tar -xzf primer3-2.6.1.tar.gz || exit $?
cd primer3-2.6.1/src || exit $?
perl -i -npe 's/^O_OPTS *= */$& -mtune=native /' Makefile || exit $?
make -j4 || exit $?
mkdir -p $PREFIX/bin || sudo mkdir -p $PREFIX/bin || exit $?
mv long_seq_tm_test ntdpal ntthal oligotm primer3_core $PREFIX/bin/ || sudo mv long_seq_tm_test ntdpal ntthal oligotm primer3_core $PREFIX/bin/ || exit $?
cd ../.. || exit $?
rm -rf primer3-2.6.1.tar.gz primer3-2.6.1 || exit $?
touch .primer3 || exit $?
fi
# download, compile, and install RAxML
if ! test -e .raxml; then
wget -c -O RAxML-8.2.12.tar.gz https://github.com/stamatak/standard-RAxML/archive/refs/tags/v8.2.12.tar.gz || exit $?
tar -xzf RAxML-8.2.12.tar.gz || exit $?
cd standard-RAxML-8.2.12 || exit $?
for f in Makefile.*; do perl -i -npe 's/^CFLAGS *= */$& -march=core2 /;s/ -march=native//' $f || exit $?; done
perl -i -npe "s/-march=core2/-march=corei7-avx/" Makefile.AVX.gcc || exit $?
perl -i -npe "s/-march=core2/-march=corei7-avx/" Makefile.AVX.PTHREADS.gcc || exit $?
perl -i -npe "s/-march=core2/-march=core-avx2/" Makefile.AVX2.gcc || exit $?
perl -i -npe "s/-march=core2/-march=core-avx2/" Makefile.AVX2.PTHREADS.gcc || exit $?
perl -i -npe "s/-D_FMA/$& -mfma/" Makefile.AVX2.gcc || exit $?
perl -i -npe "s/-D_FMA/$& -mfma/" Makefile.AVX2.PTHREADS.gcc || exit $?
make -j4 -f Makefile.gcc || exit $?
mv raxmlHPC $PREFIX/bin/ || sudo mv raxmlHPC $PREFIX/bin/ || exit $?
make -f Makefile.gcc clean || exit $?
make -j4 -f Makefile.PTHREADS.gcc || exit $?
mv raxmlHPC-PTHREADS $PREFIX/bin/ || sudo mv raxmlHPC-PTHREADS $PREFIX/bin/ || exit $?
make -f Makefile.PTHREADS.gcc clean || exit $?
make -j4 -f Makefile.AVX.gcc || exit $?
mv raxmlHPC-AVX $PREFIX/bin/ || sudo mv raxmlHPC-AVX $PREFIX/bin/ || exit $?
make -f Makefile.AVX.gcc clean || exit $?
make -j4 -f Makefile.AVX.PTHREADS.gcc || exit $?
mv raxmlHPC-PTHREADS-AVX $PREFIX/bin/ || sudo mv raxmlHPC-PTHREADS-AVX $PREFIX/bin/ || exit $?
make -f Makefile.AVX.PTHREADS.gcc clean || exit $?
make -j4 -f Makefile.AVX2.gcc || exit $?
mv raxmlHPC-AVX2 $PREFIX/bin/ || sudo mv raxmlHPC-AVX2 $PREFIX/bin/ || exit $?
make -f Makefile.AVX2.gcc clean || exit $?
make -j4 -f Makefile.AVX2.PTHREADS.gcc || exit $?
mv raxmlHPC-PTHREADS-AVX2 $PREFIX/bin/ || sudo mv raxmlHPC-PTHREADS-AVX2 $PREFIX/bin/ || exit $?
make -f Makefile.AVX2.PTHREADS.gcc clean || exit $?
make -j4 -f Makefile.SSE3.gcc || exit $?
mv raxmlHPC-SSE3 $PREFIX/bin/ || sudo mv raxmlHPC-SSE3 $PREFIX/bin/ || exit $?
make -f Makefile.SSE3.gcc clean || exit $?
make -j4 -f Makefile.SSE3.PTHREADS.gcc || exit $?
mv raxmlHPC-PTHREADS-SSE3 $PREFIX/bin/ || sudo mv raxmlHPC-PTHREADS-SSE3 $PREFIX/bin/ || exit $?
make -f Makefile.SSE3.PTHREADS.gcc clean || exit $?
cd .. || exit $?
rm -rf RAxML-8.2.12.tar.gz standard-RAxML-8.2.12 || exit $?
touch .raxml || exit $?
fi
# download, compile, and install trimAl
if ! test -e .trimal; then
wget -c -O trimal-1.4.1.tar.gz https://github.com/inab/trimal/archive/refs/tags/v1.4.1.tar.gz || exit $?
tar -xzf trimal-1.4.1.tar.gz || exit $?
cd trimal-1.4.1/source || exit $?
perl -i -npe 's/^FLAGS *= */$&-O2 -mtune=native /' makefile || exit $?
make -f makefile -j4 || exit $?
mv readal trimal statal $PREFIX/bin/ || sudo mv readal trimal statal $PREFIX/bin/ || exit $?
cd ../.. || exit $?
rm -rf trimal-1.4.1 trimal-1.4.1.tar.gz || exit $?
touch .trimal || exit $?
fi
# download, compile, and install CONSEL
if ! test -e .consel; then
wget -c http://stat.sys.i.kyoto-u.ac.jp/prog/consel/pub/cnsls020.tgz || exit $?
tar -xf cnsls020.tgz || exit $?
cd consel/src || exit $?
perl -i -npe 's/^(CFLAGS *= *)\-g */$1-O2 -mtune=native /' Makefile || exit $?
make -j4 || exit $?
make install || exit $?
cd ../bin || exit $?
mv * $PREFIX/bin/ || sudo mv * $PREFIX/bin/ || exit $?
cd ../.. || exit $?
rm -rf cnsls020.tgz consel || exit $?
touch .consel || exit $?
fi
# download, compile, and install MrBayes5D
if ! test -e .mrbayes5d; then
wget -c https://www.fifthdimension.jp/products/mrbayes5d/mrbayes5d-3.2.6.2016.11.11.zip || exit $?
unzip -qq mrbayes5d-3.2.6.2016.11.11.zip || exit $?
cd mrbayes5d-3.2.6.2016.11.11 || exit $?
sh ./configure --enable-debug=no --enable-mpi=no --enable-sse=yes --enable-threads=no --without-beagle --prefix=$PREFIX || exit $?
make -j4 || exit $?
make install || sudo make install || exit $?
make distclean || exit $?
sh ./configure --enable-debug=no --enable-mpi=yes --enable-sse=yes --enable-threads=no --without-beagle --prefix=$PREFIX || exit $?
make -j4 || exit $?
cp mrbayes5d $PREFIX/bin/mrbayes5d-mpi || sudo cp mrbayes5d $PREFIX/bin/mrbayes5d-mpi || exit $?
cd .. || exit $?
rm -rf mrbayes5d-3.2.6.2016.11.11.zip mrbayes5d-3.2.6.2016.11.11 || exit $?
touch .mrbayes5d || exit $?
fi
# download, and install FigTree
if ! test -e .figtree; then
wget -c https://github.com/rambaut/figtree/releases/download/v1.4.4/FigTree_v1.4.4.tgz || exit $?
tar -xzf FigTree_v1.4.4.tgz || exit $?
cd FigTree_v1.4.4/lib || exit $?
mkdir -p $PREFIX/share/figtree || sudo mkdir -p $PREFIX/share/figtree || exit $?
mv figtree.jar $PREFIX/share/figtree/ || sudo mv figtree.jar $PREFIX/share/figtree/ || exit $?
cd ../bin || exit $?
echo '#!/bin/sh' > figtree || exit $?
echo "$PREFIX/share/molphypack/bin/java -Xms64m -Xmx8192m -jar $PREFIX/share/figtree/figtree.jar \$*" >> figtree || exit $?
chmod 755 figtree || exit $?
mv figtree $PREFIX/bin/ || sudo mv figtree $PREFIX/bin/ || exit $?
cd ../.. || exit $?
rm -rf FigTree_v1.4.4.tgz FigTree_v1.4.4 || exit $?
touch .figtree || exit $?
fi
# download, and install Tracer
if ! test -e .tracer; then
wget -c https://github.com/beast-dev/tracer/releases/download/v1.7.2/Tracer_v1.7.2.tgz || exit $?
mkdir -p Tracer_v1.7.2 || exit $?
cd Tracer_v1.7.2 || exit $?
tar -xzf ../Tracer_v1.7.2.tgz || exit $?
cd lib || exit $?
mkdir -p $PREFIX/share/tracer || sudo mkdir -p $PREFIX/share/tracer || exit $?
mv *.jar $PREFIX/share/tracer/ || sudo mv *.jar $PREFIX/share/tracer/ || exit $?
cd ../bin || exit $?
echo '#!/bin/sh' > tracer || exit $?
echo "TRACER_LIB=$PREFIX/share/tracer" >> tracer || exit $?
echo "$PREFIX/share/molphypack/bin/java -Xms64m -Xmx8192m -jar $PREFIX/share/tracer/tracer.jar \$*" >> tracer || exit $?
chmod 755 tracer || exit $?
mv tracer $PREFIX/bin/ || sudo mv tracer $PREFIX/bin/ || exit $?
cd ../.. || exit $?
rm -rf Tracer_v1.7.2.tgz Tracer_v1.7.2 || exit $?
touch .tracer || exit $?
fi
# download, compile, and install Kakusan4
if ! test -e .kakusan4; then
wget -c https://www.fifthdimension.jp/products/kakusan/kakusan4-4.0.2016.11.07.zip || exit $?
unzip -qq kakusan4-4.0.2016.11.07.zip || exit $?
cd kakusan4-4.0.2016.11.07 || exit $?
perl -i -npe 's/^CFLAGS *= */$&-mtune=native /' Makefile.UNIX || exit $?
make -j4 -f Makefile.UNIX || exit $?
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
perl -i -npe 's/^CFLAGS *= */$&-mtune=native /' Makefile.UNIX || exit $?
make -j4 -f Makefile.UNIX || exit $?
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
make PREFIX=$PREFIX -j4 || exit $?
make PREFIX=$PREFIX install || sudo make PREFIX=$PREFIX install || exit $?
cd .. || exit $?
rm -rf Phylogears-2.0.2020.05.06.zip Phylogears-2.0.2020.05.06 || exit $?
touch .phylogears2 || exit $?
fi
echo 'Installation finished correctly!'
echo "You might need to add \"$PREFIX\" to PATH environment variable."
