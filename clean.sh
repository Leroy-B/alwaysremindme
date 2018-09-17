#!/bin/bash
echo "Cleaning up build scraps."

make clean

rm -rf obj
rm -rf packages
rm -rf .theos
rm -rf alwaysremindmepref/.theos

echo "Cleaning done."

echo "Building FINALPACKAGE."

make package install FINALPACKAGE=1

echo "Building done."
