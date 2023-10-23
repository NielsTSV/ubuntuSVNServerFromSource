mkdir /home/svn
mkdir /home/svn/svnrepo
svnadmin create /home/svn/svnrepo
mkdir /home/workingcopy
svn checkout file:////home/svn/svnrepo /home/workingcopy/
echo "print(\"hello world! first svn file\")" > /home/workingcopy/helloworld.py
cd /home/workingcopy
svn add helloworld.py
svn commit -m "commit message"
chown -R www-data:www-data /home/svn/svnrepo/