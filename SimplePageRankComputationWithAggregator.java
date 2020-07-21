package org.apache.giraph.examples;

/*
http://buttercola.blogspot.com/2015/04/giraph-page-rank.html
 */
 
import org.apache.giraph.aggregators.DoubleMaxAggregator;
import org.apache.giraph.aggregators.DoubleMinAggregator;
import org.apache.giraph.aggregators.LongSumAggregator;
import org.apache.giraph.edge.Edge;
import org.apache.giraph.edge.EdgeFactory;
import org.apache.giraph.graph.BasicComputation;
import org.apache.giraph.graph.Vertex;
import org.apache.giraph.io.VertexReader;
import org.apache.giraph.io.formats.GeneratedVertexInputFormat;
import org.apache.giraph.io.formats.TextVertexOutputFormat;
import org.apache.giraph.master.DefaultMasterCompute;
import org.apache.giraph.worker.WorkerContext;
import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.FloatWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.log4j.Logger;
 
import com.google.common.collect.Lists;
 
import java.io.IOException;
import java.util.List;
public class SimplePageRankComputationWithAggregator extends BasicComputation<LongWritable,
    DoubleWritable, FloatWritable, DoubleWritable> {
  /** Number of supersteps for this test */
  public static final int MAX_SUPERSTEPS = 30;
  /** Logger */
  private static final Logger LOG = 
      Logger.getLogger(SimplePageRankComputationWithAggregator.class);
  /** Sum aggregator name */
  private static String SUM_AGG = "sum";
  /** Min aggregator name */
  private static String MIN_AGG = "min";
  /** Max aggregator name */
  private static String MAX_AGG = "max";
 
  @Override
  public void compute(
      Vertex<LongWritable, DoubleWritable, FloatWritable> vertex, 
      Iterable<DoubleWritable> messages) throws IOException {
    if (getSuperstep() > 0) {
      double sum = 0;
      for (DoubleWritable message : messages) {
        sum += message.get();
      }
      DoubleWritable vertexValue = 
          new DoubleWritable(0.15f / getTotalNumVertices() + 0.85f * sum);
      vertex.setValue(vertexValue);
      aggregate(MAX_AGG, vertexValue);
      aggregate(MIN_AGG, vertexValue);
      aggregate(SUM_AGG, new LongWritable(1));
      LOG.info(vertex.getId() + ": PageRank=" + vertexValue + 
          " max=" + getAggregatedValue(MAX_AGG) + 
          " min=" + getAggregatedValue(MIN_AGG));
    }
 
    if (getSuperstep() < MAX_SUPERSTEPS) {
      long edges = vertex.getNumEdges();
      sendMessageToAllEdges(vertex, 
          new DoubleWritable(vertex.getValue().get() / edges));
    } else {
      vertex.voteToHalt();
    }
  }
 
  /**
   * Master compte 
   * It registers required aggregators
   */
  public static class SimplePageRankMasterCompute extends
      DefaultMasterCompute {
    @Override
    public void initialize() throws InstantiationException,
        IllegalAccessException {
      registerAggregator(SUM_AGG, LongSumAggregator.class);
      registerPersistentAggregator(MIN_AGG, DoubleMinAggregator.class);
      registerPersistentAggregator(MAX_AGG, DoubleMaxAggregator.class);
    }
  }
}
