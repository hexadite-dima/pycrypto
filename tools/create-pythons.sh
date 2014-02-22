#!/bin/bash
# Experimental script used to install multiple versions of Python for testing PyCrypto.
# Edit it to suit your needs.
# by Dwayne Litzenberger
#
# The contents of this file are dedicated to the public domain.  To
# the extent that dedication to the public domain is not available,
# everyone is granted a worldwide, perpetual, royalty-free,
# non-exclusive license to exercise all rights associated with the
# contents of this file for any purpose whatsoever.
# No rights are reserved.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e

apply_multiarch_hack_patch() {
patch -p1 <<'EOF'
--- a/setup.py	2008-10-16 11:58:19.000000000 -0700
+++ b/setup.py	2013-02-02 19:05:15.398794396 -0800
@@ -246,6 +246,7 @@
         # Ensure that /usr/local is always used
         add_dir_to_list(self.compiler.library_dirs, '/usr/local/lib')
         add_dir_to_list(self.compiler.include_dirs, '/usr/local/include')
+        add_dir_to_list(self.compiler.library_dirs, os.getenv("EXTRA_LIBDIR"))
 
         # Add paths specified in the environment variables LDFLAGS and
         # CPPFLAGS for header and library files.
EOF
}

PREFIX=${PREFIX:-$(dirname "$(readlink -f "$0")")/py}
CONCURRENCY_LEVEL=${CONCURRENCY_LEVEL:-5}

# Unexport vars
export -n PREFIX CONCURRENCY_LEVEL

#
# Download
#

mkdir -p "$PREFIX/src" "$PREFIX/archives" "$PREFIX/build" "$PREFIX/pythons"
cd "$PREFIX/archives"

wget -c -i- <<-'EOF'
http://www.python.org/ftp/python/2.1.3/Python-2.1.3.tgz
http://www.python.org/ftp/python/2.2.3/Python-2.2.3.tgz
http://www.python.org/ftp/python/2.3.7/Python-2.3.7.tar.bz2
http://www.python.org/ftp/python/2.4.6/Python-2.4.6.tar.bz2
http://www.python.org/ftp/python/2.5.6/Python-2.5.6.tar.bz2
http://www.python.org/ftp/python/2.6.8/Python-2.6.8.tar.bz2
http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tar.bz2
http://www.python.org/ftp/python/3.0.1/Python-3.0.1.tar.bz2
http://www.python.org/ftp/python/3.1.5/Python-3.1.5.tar.bz2
http://www.python.org/ftp/python/3.2.3/Python-3.2.3.tar.bz2
http://www.python.org/ftp/python/3.3.0/Python-3.3.0.tar.bz2
http://www.python.org/ftp/python/3.4.0/Python-3.4.0rc1.tgz
EOF

# HACK - "wget -c" doesn't properly handle sites like this that don't support the Range header
wget -nc -i- <<-'EOF'
https://gist.github.com/raw/1929293/18b5c29262ea04d0802e998da368e14b73112bda/fix-python-2.5.6-svnversion-issue.patch
EOF

# Check MD5 checksums (mostly transcribed from www.python.org, up to v3.3)
md5sum -c <<-'EOF'
a8b04cdc822a6fc833ed9b99c7fba589 *Python-2.1.3.tgz
169f89f318e252dac0c54dd1b165d229 *Python-2.2.3.tgz
fa73476c5214c57d0751fae527f991e1 *Python-2.3.7.tar.bz2
76083277f6c7e4d78992f36d7ad9018d *Python-2.4.6.tar.bz2
5d45979c5f30fb2dd5f067c6b06b88e4 *Python-2.5.6.tar.bz2
c6e0420a21d8b23dee8b0195c9b9a125 *Python-2.6.8.tar.bz2
c57477edd6d18bd9eeca2f21add73919 *Python-2.7.3.tar.bz2
7291eac6a9a7a3642e309c78b8d744e5 *Python-3.0.1.tar.bz2
dc8a7a96c12880d2e61e9f4add9d3dc7 *Python-3.1.5.tar.bz2
cea34079aeb2e21e7b60ee82a0ac286b *Python-3.2.3.tar.bz2
b3b2524f72409d919a4137826a870a8f *Python-3.3.0.tar.bz2
8f75b4e8e907bc17d9e4478da1bd0f0f *Python-3.4.0rc1.tgz
871fac364185ba4b94a74f6245f08f34 *fix-python-2.5.6-svnversion-issue.patch
EOF
#1d00e2fb19418e486c30b850df625aa3 *Python-2.5.5.tar.bz2
#cf4e6881bb84a7ce6089e4a307f71f14 *Python-2.6.6.tar.bz2
#aa27bc25725137ba155910bd8e5ddc4f *Python-2.7.1.tar.bz2
#ad5e5f1c07e829321e0a015f8cafe245 *Python-3.1.3.tar.bz2
#9d763097a13a59ff53428c9e4d098a05 *Python-3.2.2.tar.bz2
#45ab5ff5edfb73ec277b1c763f3d5a42 *Python-3.2b2.tar.bz2

# Check SHA256 checksums (originally generated by me)
if which sha256sum >/dev/null ; then
	sha256sum -c <<-'EOF'
1bcb5bb587948bc38f36db60e15c376009c56c66570e563a08a82bf7f227afb9 *Python-2.1.3.tgz
a8f92e6b89d47359fff0d1fbfe47f104afc77fd1cd5143e7332758b7bc100188 *Python-2.2.3.tgz
4bd3aebaa1fe8e30afee9f0f968e699509b73ed5cff270b608216293515359f0 *Python-2.3.7.tar.bz2
da104139ad3f4534482942ac02cf8f8ed9badd370ffa14f06b07c44914423e08 *Python-2.4.6.tar.bz2
57e04484de051decd4741fb4a4a3f543becc9a219af8b8063b5541e270f26dcc *Python-2.5.6.tar.bz2
c34036718ee1f091736677f543bc7960861cf9fcbea77d49572b59f7f1ab3c3f *Python-2.6.8.tar.bz2
726457e11cb153adc3f428aaf1901fc561a374c30e5e7da6742c0742a338663c *Python-2.7.3.tar.bz2
91afb6ac16d3d22bc6bfbc80726dc85ede32bf838f660cc67016c7d0a7079add *Python-3.0.1.tar.bz2
3a72a21528f0751e89151744350dd12004131d312d47b935ce8041b070c90361 *Python-3.1.5.tar.bz2
5648ec81f93870fde2f0aa4ed45c8718692b15ce6fd9ed309bfb827ae12010aa *Python-3.2.3.tar.bz2
15c113fd6c058712f05d31b4eff149d4d823b8e39ef5e37228dc5dc4f8716df9 *Python-3.3.0.tar.bz2
95fae4e71ffd4b442527a379f1a7d8ca7ac1ca3c60f3c740fe06d8562814722f *Python-3.4.0rc1.tgz
46c40e269b073155f7b5c2e2aa7abdac55b0756d6239def317fff81f7d5088d7 *fix-python-2.5.6-svnversion-issue.patch
	EOF
#2623a04d40123950eb2a459aa39805f48f6254c21b4c0fcfa430d5eca8a0389b *Python-2.5.5.tar.bz2
#134c5e0736bae2e5570d0b915693374f11108ded63c35a23a35d282737d2ce83 *Python-2.6.6.tar.bz2
#80e387bcf57eae8ce26726753584fd63e060ec11682d1145af921e85fd612292 *Python-2.7.1.tar.bz2
#77f6f41a51be4ca85d83670405c8281dd1237bb00d8be8a7560cb3ccdf5558cb *Python-3.1.3.tar.bz2
#0bead812d9fbd56826f90b30150d8eb75ce56520b05f6a3a0dc474ef7aa927a3 *Python-3.2b2.tar.bz2
#11426a3c6e4a33e343f100b092049d0a3e09de1c7a2fbf5f0086a8282db59dee *Python-3.2.2.tar.bz2
else
	echo >&2 "$0: warning: No sha256sum command; skipping check."
fi

#
# Extract
#
for filename in \
	Python-2.1.3.tgz Python-2.2.3.tgz \
	Python-2.3.7.tar.bz2 Python-2.4.6.tar.bz2 Python-2.5.6.tar.bz2 \
	Python-2.6.8.tar.bz2 Python-2.7.3.tar.bz2 Python-3.0.1.tar.bz2 \
	Python-3.1.5.tar.bz2 Python-3.2.3.tar.bz2 Python-3.3.0.tar.bz2 \
	Python-3.4.0rc1.tgz
do
	dir="`basename "$filename"`"
	dir=${dir%%.tgz}
	dir=${dir%%.tar.bz2}

	name=`echo "$dir" | tr 'A-Z' 'a-z' | sed -e 's/-//g'`
	name=${name%%.[0-9]}

	echo "#########################"
	echo "### Building $dir ($name)"
	echo "### in $PREFIX/build/$dir"
	echo "#########################"

	# Extract
	if [ -d "$PREFIX/src/$dir" ] ; then
		echo "$name: Skipping $filename ($dir exists)"
	else
		echo "$name: Extracting $filename ..."
		mkdir -p "$PREFIX/src/tmp"
		cd "$PREFIX/src/tmp"
		case "$filename" in
		*.tgz)
			tar xzf "$PREFIX/archives/$filename"
			;;
		*.tar.bz2)
			tar xjf "$PREFIX/archives/$filename"
			;;
		*)
			echo >&2 "Don't know how to handle $filename"
			exit 1
		esac
		mv "$dir" "$PREFIX/src/"
	fi

        # Apply patches
        cd "$PREFIX/src/$dir"
        if ! [ -e .fix-python-2.5.6-svnversion-issue.patch.applied ] && [ "$dir" = "Python-2.5.6" -o "$dir" = "Python-3.0.1" ] ; then
            patch -p1 < "$PREFIX/archives/fix-python-2.5.6-svnversion-issue.patch"
            touch .fix-python-2.5.6-svnversion-issue.patch.applied
        fi
        if ! [ -e .ssl-fix.applied ] && [ "$dir" = "Python-2.5.6" ] ; then
            echo "_ssl _ssl.c -lssl -lcrypto" >> Modules/Setup.dist
            touch .ssl-fix.applied
        fi
        if ! [ -e .multiarch-hack.applied ] && [ "$dir" = "Python-2.5.6" -o "$dir" = "Python-2.6.8" -o "$dir" = "Python-3.0.1" ] && gcc -print-multiarch >/dev/null ; then
            # This is a glorious hack to get sqlite & hashlib to build properly on Debian/Ubuntu multiarch.
            apply_multiarch_hack_patch
            touch .multiarch-hack.applied
            export EXTRA_LIBDIR=/usr/lib/`gcc -print-multiarch`
        fi

        # Set some special configure parameters
	if [ `uname -m` = "x86_64" ] && [ "$name" = "python2.3" ] ; then
		# Workaround for bug in Ubuntu 10.10 amd64 gcc-4.4
		# See http://orip.org/2008/10/building-python-235-on-ubuntu-intrepid.html
		# and Ubuntu Bug #286334 
		extra_config_params=BASECFLAGS=-U_FORTIFY_SOURCE
	else
		extra_config_params=
	fi

        # Profiling support?
        if [ "$PROFILING" -eq 1 ] ; then
            extra_config_params="$extra_config_params --enable-profiling"
        fi

	# Create build directory, configure, and build
	set -x
	mkdir -p "$PREFIX/build/$dir" "$PREFIX/pythons/$name"
	cd "$PREFIX/build/$dir"
	"$PREFIX/src/$dir/configure" $extra_config_params --prefix="$PREFIX/pythons/$name" --enable-unicode=ucs4
	make -s -j"$CONCURRENCY_LEVEL"
	make -s install
	set +x
done
