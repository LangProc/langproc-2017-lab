#!/bin/bash

echo "========================================"
echo " Cleaning the temporaries and outputs"
make clean
echo " Force building bin/print_canonical"
make bin/print_canonical -B
if [[ "$?" -ne 0 ]]; then
    echo "Build failed.";
fi
echo ""

echo "========================================="
echo "Checking that good expressions are parsed"

PASSED=0
CHECKED=0

if [[ -f test/valid_expressions.got.txt ]]; then
    rm test/valid_expressions.got.txt
fi
while IFS=, read -r INPUT_LINE REF_LINE; do
    echo "==========================="
    echo ""
    echo "Input : ${INPUT_LINE}"
    GOT_LINE=$( echo -n "${INPUT_LINE}" | bin/print_canonical )
    echo "Output : ${GOT_LINE}"
    echo "${INPUT_LINE},${GOT_LINE}" >> test/valid_expressions.got.txt
    if [[ "${GOT_LINE}" != "${REF_LINE}" ]]; then
        echo "ERROR"
    else
        PASSED=$(( ${PASSED}+1 ));
    fi
    CHECKED=$(( ${CHECKED}+1 ));
done < <( cat test/valid_expressions.input.txt | dos2unix )

echo ""
echo "========================================="
echo "Checking that bad expressions are not parsed"

while IFS=, read -r INPUT_LINE; do
    echo "==========================="
    echo ""
    echo "Input : ${INPUT_LINE}"
    GOT_LINE=$( echo -n "${INPUT_LINE}" | bin/print_canonical )
    CODE=$?;
    echo "Output : ${GOT_LINE}"
    echo "Exit code : ${CODE}"
    if [[ ${CODE} -eq "0" ]]; then
        echo "ERROR"
    else
        PASSED=$(( ${PASSED}+1 ));
    fi
    CHECKED=$(( ${CHECKED}+1 ));
done < <( cat test/invalid_expressions.input.txt | dos2unix )


echo "########################################"
echo "Passed ${PASSED} out of ${CHECKED}".
echo ""

RELEASE=$(lsb_release -d)
if [[ $? -ne 0 ]]; then
    echo ""
    echo "Warning: This appears not to be a Linux environment"
    echo "         Make sure you do a final run on a lab machine or an Ubuntu VM"
else
    grep -q "Ubuntu 16.04" <(echo $RELEASE)
    FOUND=$?

    if [[ $FOUND -ne 0 ]]; then
        echo ""
        echo "Warning: This appears not to be the target environment"
        echo "         Make sure you do a final run on a lab machine or an Ubuntu VM"
    fi
fi
