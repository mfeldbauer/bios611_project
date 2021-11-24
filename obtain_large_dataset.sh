#!/bin/bash

wget -N https://cbioportal-datahub.s3.amazonaws.com/brca_metabric.tar.gz -P /tmp/
tar -xzvf /tmp/brca_metabric.tar.gz -C /tmp/

du -k /tmp/brca_metabric/* > /tmp/file_sizes.txt
while IFS= read -r line
do
        size=$(echo "$line" | awk '{print $1}')
        if [ $size -gt 500000 ]
        then
		file_name=$(echo "$line" | awk '{print $2}')
        fi
done < /tmp/file_sizes.txt

mv $file_name "$(pwd)"/source_data/
