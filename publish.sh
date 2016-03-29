#!/bin/sh -xe

ecmarkup spec/index.html index.next
git checkout gh-pages
mv index.next index.html
git add index.html
git commit -m 'Publish'
git push origin gh-pages
git checkout master