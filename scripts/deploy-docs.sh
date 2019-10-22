git fetch &&
git checkout gh-pages &&
make docs &&
git add docs && 
git commit -m 'Updated docs' &&
git push -u origin gh-pages
