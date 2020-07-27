
cd $HOME

echo "Starting up."
wget http://archive.apache.org/dist/hadoop/core/hadoop-0.20.205.0/hadoop-0.20.205.0.tar.gz
tar xzf hadoop-0.20.205.0.tar.gz
mv hadoop-0.20.205.0 $HOME/hadoop
rm hadoop-0.20.205.0.tar.gz
echo "Hadoop downloaded and moved to home directory."


echo "Writing bashrc."

echo "export HADOOP_HOME=/home/fp-ss20/hadoop" >> .bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> .bashrc
echo "export GIRAPH_HOME=/home/fp-ss20/giraph" >> .bashrc

source .bashrc

echo "Writing hadoop-env"

echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> hadoop/conf/hadoop-env.sh
echo "export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true" >> hadoop/conf/hadoop-env.sh



echo "creating tmp folder for hadoop"
mkdir hadoop-tmp


echo "TODO: HADOOP/conf files"

