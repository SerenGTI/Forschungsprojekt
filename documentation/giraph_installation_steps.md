
Unfinished! Doesn't work yet

# Prerequisites
First install Open JDK, git and maven
```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install default-jdk git maven
```

We will not use a different user for the installation.
(optional?)
Create a new group hadoop and user hduser
```
sudo addgroup hadoop
sudo adduser --ingroup hadoop hduser
```



## Download and install hadoop.
```
cd /usr/local
sudo wget http://archive.apache.org/dist/hadoop/core/hadoop-0.20.203.0/hadoop-0.20.203.0rc1.tar.gz
sudo tar xzf hadoop-0.20.203.0rc1.tar.gz
sudo mv hadoop-0.20.203.0 hadoop

(optional?)
```
Allow read rights to hadoop group
```
sudo chown -R hduser:hadoop hadoop
```

(stattdessen)
sudo chown -R ubuntu hadoop




Find the name of the installed JDK folder by running 
```
ls /usr/lib/jvm
```
for us it was `/usr/lib/jvm/java-11-openjdk-amd64`. Use this path in the following commands.

Switch to the hduser using `su hduser` and append the following to their `$HOME/.bashrc`
```
export HADOOP_HOME=/usr/local/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export GIRAPH_HOME=/usr/local/giraph
```
Close, save and reload it.
```
source ~/.bashrc
```
Now edit `/usr/local/hadoop/conf/hadoop-env.sh`
```
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true
```


Create a temporary directory for hadoop to work on
```
sudo mkdir -p /app/hadoop/tmp
sudo chown hduser:hadoop /app/hadoop/tmp
//sudo chown ubuntu /app/hadoop/tmp
sudo chmod 750 /app/hadoop/tmp
```


Now check that the `/etc/hosts` is correctly configured with
```
127.0.0.1 localhost
<IP> <hostname>
```
make sure to replace IP and hostname with the current IP of this machine and the hostname with the corresponding hostname.


## Configuring Hadoop
in conf/* .xml
hdnode01 durch hostname (koenigsn_giraph) ersetzen

in core-site.xml den teil mit 
<property> 
<name>fs.default.name</name> 
<value>hdfs://koenigsn_giraph:54310</value> 
</property>
weglassen..?

außerdem wenn man localhost in core-site benutzt gehts..
Einfach IP-Adressen verwenden?


in slaves und masters jeweils localhost entfernen! sonst werden mache sachen irgendwie doppelt und andere gar nicht gestartet

namenode format entweder als hduser oder im richtigen verzeichnis, ubuntu kennt $HADOOP_HOME nicht



## Installing Giraph
```
cd /usr/local/
sudo git clone https://github.com/apache/giraph.git
sudo chown -R ubuntu giraph
```
Now install the package using maven. We recommend piping the output to `/dev/null` since it is quite a lot of useless text.
```
cd $GIRAPH_HOME
mvn package -DskipTests > /dev/null
```
You should now however verify the correct installation afterwards.
We should
```
ls $GIRAPH_HOME/giraph-examples/target
```

# Running Giraph Jobs
THIS DOES NOT WORK YET
```
$HADOOP_HOME/bin/hadoop jar $GIRAPH_HOME/giraph-examples/target/giraph-examples-1.3.0-SNAPSHOT-for-hadoop-1.2.1-jar-with-dependencies.jar org.apache.giraph.GiraphRunner org.apache.giraph.examples.SimpleShortestPathsComputation -vif org.apache.giraph.io.formats.JsonLongDoubleFloatDoubleVertexInputFormat -vip /user/hduser/input/tiny_graph.txt -vof org.apache.giraph.io.formats.IdWithValueTextOutputFormat -op /user/hduser/output/shortestpaths -w 1
```
