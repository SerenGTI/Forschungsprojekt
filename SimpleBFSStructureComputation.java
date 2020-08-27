/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


/*
	Retrieved from https://github.com/MarcoLotz/GiraphBFSSO
 */

//package uk.co.qmul.giraph.structurebfs; //removed
package org.apache.giraph.examples;

import org.apache.giraph.Algorithm;
import org.apache.giraph.graph.BasicComputation;
import org.apache.giraph.conf.LongConfOption;
import org.apache.giraph.edge.Edge;
import org.apache.giraph.graph.Vertex;
import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.FloatWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.log4j.Logger;

import java.io.IOException;

/**
 * Demonstrates the basic Pregel Breadth First Search applied to graph
 * structure.
 * 
 * SimpleBFSComputation is the basic class with the configurations for a BFS
 * search and the basic configurations for it. The "Structure" means that it
 * computes the whole structure in order to check the depth from the start
 * vertex
 * 
 * @author Marco Aurelio Lotz
 */
@Algorithm(name = "Breadth First Search Structural oriented", description = "Uses Breadth First Search from a source vertex to calculate depths")
public class SimpleBFSStructureComputation
		extends
		BasicComputation<LongWritable, DoubleWritable, FloatWritable, DoubleWritable> {

	// added the following for dynamic start vertices
	private static long startVertexId;
	public static void main(String[] args) {
		startVertexId = Long.valueOf(args[0]);
	}
	// until here


	/**
	 * Define a maximum number of supersteps
	 */
	public final int MAX_SUPERSTEPS = 9999;

	// changed to dynamic start vertex
	/**
	 * Indicates the first vertex to be computed in superstep 0.
	 */
	public static final LongConfOption START_ID = new LongConfOption(
			"SimpleBFSComputation.START_ID", startVertexId,
			"Is the first vertex to be computed");

	/** Class logger */
	private static final Logger LOG = Logger
			.getLogger(SimpleBFSStructureComputation.class);

	/**
	 * Is this vertex the start vertex?
	 * 
	 * @param vertex
	 * @return true if analysed node is the start vertex
	 */
	private boolean isStart(Vertex<LongWritable, ?, ?> vertex) {
		return vertex.getId().get() == START_ID.get(getConf());
	}

	/**
	 * Send messages to all the connected vertices. The content of the messages
	 * is not important, since just the event of receiving a message removes the
	 * vertex from the inactive status.
	 * 
	 * @param vertex
	 */
	public void BFSMessages(
			Vertex<LongWritable, DoubleWritable, FloatWritable> vertex) {
		for (Edge<LongWritable, FloatWritable> edge : vertex.getEdges()) {
			sendMessage(edge.getTargetVertexId(), new DoubleWritable(1d));
		}
	}

	@Override
	public void compute(
			Vertex<LongWritable, DoubleWritable, FloatWritable> vertex,
			Iterable<DoubleWritable> messages) throws IOException {

		// Forces convergence in maximum superstep
		if (!(getSuperstep() == MAX_SUPERSTEPS)) {
			// Only start vertex should work in the first superstep
			// All the other should vote to halt and wait for
			// messages.
			if (getSuperstep() == 0) {
				if (isStart(vertex)) {
					vertex.setValue(new DoubleWritable(getSuperstep()));
					BFSMessages(vertex);
					if (LOG.isInfoEnabled()) {
						LOG.info("[Start Vertex] Vertex ID: " + vertex.getId());
					}
				} else { // Initialise with infinite depth other vertex
					vertex.setValue(new DoubleWritable(Integer.MAX_VALUE));
				}
			}

			// if it is not the first Superstep (Superstep 0) :
			// Check vertex ID

			else {
				// It is the first time that this vertex is being computed
				if (vertex.getValue().get() == Integer.MAX_VALUE) {
					// The depth has the same value that the superstep
					vertex.setValue(new DoubleWritable(getSuperstep()));
					// Continue on the structure
					BFSMessages(vertex);
				}
				// Else this vertex was already analysed in a previous
				// iteration.
			}
			vertex.voteToHalt();
		}
	}
}
