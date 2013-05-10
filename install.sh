rm -rf ~/.vim
rm -f ~/.vimrc
ln -s `pwd`/vim ~/.vim
ln -s `pwd`/vimrc ~/.vimrc

rm -rf ~/.vim/bundle
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

vim -c "BundleInstall" -c "qa"
