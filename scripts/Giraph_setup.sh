
# This will install hadoop and giraph,
# however it will NOT configure:
# * /etc/hosts


#prerequisites
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install default-jdk git maven net-tools

#install hadoop
cd /usr/local
sudo wget http://archive.apache.org/dist/hadoop/core/hadoop-0.20.205.0/hadoop-0.20.205.0.tar.gz
sudo tar xzf hadoop-0.20.205.0.tar.gz
sudo mv hadoop-0.20.205.0 hadoop
sudo rm hadoop-0.20.205.0.tar.gz

#permissions to hadoop folder
sudo chown -R $USER hadoop

#.bashrc, except not
export HADOOP_HOME=/usr/local/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export GIRAPH_HOME=/usr/local/giraph

#hadoop-env
echo "export JAVA_HOME=/usr/lib/jvm/default-java
export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true" >> /usr/local/hadoop/conf/hadoop-env.sh

#hadoop tmp folder
sudo mkdir -p /app/hadoop/tmp
sudo chown $USER /app/hadoop/tmp
sudo chmod 750 /app/hadoop/tmp
