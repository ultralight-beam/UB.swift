git fetch &&
git checkout gh-pages &&
make docs &&
git add . && 
git commit -m 'Update docs' &&
git push -u origin gh-pages
