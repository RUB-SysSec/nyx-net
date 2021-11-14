echo "Executing dcmtk Setup Script" | ./hcat 

mkdir /tmp/ACME_STORE

./hget setup/dcmqrscp.cfg dcmqrscp.cfg
./hget setup/dicom.dic /tmp/dicom.dic
./hget setup/CT_5f947d0a797b6398.dcm /tmp/ACME_STORE/CT_5f947d0a797b6398.dcm
./hget setup/index.dat /tmp/ACME_STORE/index.dat


export DCMDICTPATH=/tmp/dicom.dic

echo "dcmtk Setup Script finished" | ./hcat 

