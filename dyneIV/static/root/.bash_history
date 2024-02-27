
ls
ls -la
cat /root/.gitconfig 
cat /root/.dotfiles/git/gitconfig 
cd /root/.dotfiles/git/
git co .
awk '{print $0}' \                
cat gitconfig 
git checkout .
awk '{print $0}' gitconfig 
awk '/^.user/{next} /name =/{next} /email=/{next} {print $0}' gitconfig 
awk '/^.user/{next} /name =/{next} /email =/{next} {print $0}' gitconfig 
cat /root/.gitconfig 
ls
cat /root/.gitconfig 
cat /root/.dotfiles/git/gitconfig 
cd /root/.dotfiles/git/
git co .
awk '{print $0}' \                
cat gitconfig 
git checkout .
awk '{print $0}' gitconfig 
awk '/^.user/{next} /name =/{next} /email=/{next} {print $0}' gitconfig 
awk '/^.user/{next} /name =/{next} /email =/{next} {print $0}' gitconfig 
cat /root/.gitconfig 
rm -rf /root/.dotfiles/
sh dotfiles.sh 
cd /root/.dotfiles/
cd ~
rmdir .dotfiles/
make
export HOME=/home/dyne
setuidgid dyne sh dotfiles.sh 
cd /home/dyne/
cd .dot
rm -rf .dotfiles/
git clone https://github.com/jaromil/dotfiles .dotfiles
pwd
cd .dotfiles/
rm -rf .git*
chown -R dyne:dyne dyne/
ls -la
cd home/dyne/
cd .dotfiles
cd ..
ls
