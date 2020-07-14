
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
sudo chown <username> /app/hadoop/tmp
sudo chmod 750 /app/hadoop/tmp
```


Now check that the `/etc/hosts` is correctly configured with
```
127.0.0.1 localhost
<IP> <hostname>
```
make sure to replace IP and hostname with the current IP of this machine and  hostname with a hostname for this machine. It does not need to be the same as `hostname`. `master` or `slave1` is allowed. Use this hostname in the configuration below.
Find out the ip with
```
ifconfig
```
and note that it might differ from the one used to ssh into the machine.


## Configuring Hadoop for a single node cluster
We are working in the `$HADOOP_HOME/conf` directory. Add the following between the `<configuration>...</configuration>` in the files specified below.
In `core-site.xml`
```
<property>
<name>hadoop.tmp.dir</name>
<value>/app/hadoop/tmp</value>
</property>

<property> 
<name>fs.default.name</name> 
<value>hdfs://<hostname>:54310</value> 
</property>
```

In `mapred-site.xml`
```
<property>
<name>mapred.job.tracker</name> 
<value><hostname>:54311</value>
</property>

<property>
<name>mapred.tasktracker.map.tasks.maximum</name>
<value>4</value>
</property>

<property>
<name>mapred.map.tasks</name>
<value>4</value>
</property>
```

In `hdfs-site.xml`
```
<property>
<name>dfs.replication</name> 
<value>1</value> 
</property>
```
The value here represents the amount of datanodes.


### Set up ssh between the nodes without passwords
add the ssh keys of each node to the authorized keys of each other node.
This is for a single node cluster
```
ssh-keygen -t rsa -P ""
cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
```


### Configuring Slaves and Masters
In `$HADOOP_HOME/conf/slaves` and `$HADOOP_HOME/conf/masters` you will need to specify which nodes should be the master and which are slaves.

For a single node cluster we will change both files to only contain `<hostname>`.


### Formatting the Hadoop DFS and starting all processes
The following will format the file system.
```
$HADOOP_HOME/bin/hadoop namenode -format
```
Now start up the deamons
```
$HADOOP_HOME/bin/start-dfs.sh
$HADOOP_HOME/bin/start-mapred.sh
```

Check that everything worked by running `jps`. The output should be something like the following (on a single node cluster, ignore the PIDs)
```
12880 SecondaryNameNode
14272 Jps
13169 TaskTracker
12513 NameNode
12691 DataNode
12985 JobTracker
```



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

```
$HADOOP_HOME/bin/hadoop jar $GIRAPH_HOME/giraph-examples/target/giraph-examples-1.3.0-SNAPSHOT-for-hadoop-1.2.1-jar-with-dependencies.jar org.apache.giraph.GiraphRunner org.apache.giraph.examples.SimpleShortestPathsComputation -vif org.apache.giraph.io.formats.JsonLongDoubleFloatDoubleVertexInputFormat -vip /user/ubuntu/input/tiny_graph.txt -vof org.apache.giraph.io.formats.IdWithValueTextOutputFormat -op /user/ubuntu/output/shortestpaths -w 1
```







ubuntu@koenigsn-giraph:/usr/local/giraph/giraph-examples/src/main/java/org/apache/giraph/examples$ ls
ConnectedComponentsComputation.java
SimplePageRankComputation.java
SimpleShortestPathsComputation.java
PageRankComputation.java
RandomWalkComputation.java
[...]
